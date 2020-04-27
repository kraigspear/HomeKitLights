//
//  HomeKitAccess.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import HomeKit
import os.log

/// Errors that can occur when accessing HomeKit
enum HomeKitAccessError: Error {
    /// There isn't a home associated with this account / device
    /// Nothing can happen.
    /// A good course of action would be to inform the user how to setup HomeKit
    case homeNotFound
}

/// Access to HomeKit data
protocol HomeKitAccessible {
    /// HomeKit rooms associated with this account / device
    /// - Remarks: Only rooms for the first home is returned. Multiple homes are not supported.
    var rooms: AnyPublisher<Rooms, HomeKitAccessError> { get }

    /// Reload any room changes.
    func reload()

    /// Toggle on off state
    /// - Parameter room: Room to update
    func toggle(_ room: Room) -> AnyPublisher<Void, Error>

    /// Update the brightness value for a room
    /// - Parameters:
    ///   - brightness: The brightness value to set
    ///   - room: Room to set the brightness on
    func updateBrightness(_ brightness: Int,
                          forRoom room: Room) -> AnyPublisher<Void, Error>

    /// Authorization status of HomeKit
    var authorizationStatus: AnyPublisher<HMHomeManagerAuthorizationStatus, Never> { get }
}

/**
 Convert HomeKit objects from `HMHomeManager` to App Specific model objects.
 */
final class HomeKitAccess: NSObject, HomeKitAccessible {
    // MARK: - Members

    private let log = Log.homeKitAccess

    /// Manager used to access home kit
    private var homeKitHomeManager: HMHomeManager!

    private let homeKitAccessoryDelegate = HomeKitAccessoryDelegates()

    /// Queue to execute HomeKit operations on
    private let updateHomeKitQueue = OperationQueue()

    // MARK: - Init

    override init() {
        super.init()
        updateHomeKitQueue.maxConcurrentOperationCount = 5
        updateHomeKitQueue.qualityOfService = .userInitiated
        sinkToHomeKitAccessoryChanged()
    }

    // MARK: - Rooms

    /// Rooms subject. Set when rooms have been loaded
    private let roomsCurrentValueSubject = CurrentValueSubject<Rooms, HomeKitAccessError>([])

    /// HomeKit rooms associated with this account / device
    /// - Remarks: Only rooms for the first home is returned. Multiple homes are not supported.
    var rooms: AnyPublisher<Rooms, HomeKitAccessError> {
        roomsCurrentValueSubject.eraseToAnyPublisher()
    }

    // MARK: - Loading

    private var accessoryUpdatedCancel: AnyCancellable?

    private func sinkToHomeKitAccessoryChanged() {
        accessoryUpdatedCancel = homeKitAccessoryDelegate.accessoryUpdated.sink { _ in
            self.reload()
        }
    }

    func reload() {
        os_log("reload",
               log: log,
               type: .info)

        // Newing up a new HMHomeManager gives us the most up to date info about accessories.
        // You can setup delegates to get changes made in other Apps which seems like overkill
        // since this code gets a snapshot of data on foreground / loading.
        //
        // The actual loading will happen in the delegate
        homeKitHomeManager = HMHomeManager()
        homeKitHomeManager.delegate = self
    }

    func updateBrightness(_ brightness: Int,
                          forRoom room: Room) -> AnyPublisher<Void, Error> {
        UpdateBrightnessInRoom(room: room,
                               brightness: brightness,
                               homeKitHomeManager: homeKitHomeManager,
                               operationQueue: updateHomeKitQueue).update().eraseToAnyPublisher()
    }

    /// Toggle off on state for a room
    /// - Parameter room: Room to toggle
    func toggle(_ room: Room) -> AnyPublisher<Void, Error> {
        UpdatePowerInRoom(room: room,
                          homeKitHomeManager: homeKitHomeManager,
                          operationQueue: updateHomeKitQueue).update().eraseToAnyPublisher()
    }

    private let authorizationStatusValue = CurrentValueSubject<HMHomeManagerAuthorizationStatus, Never>(HMHomeManager().authorizationStatus)

    var authorizationStatus: AnyPublisher<HMHomeManagerAuthorizationStatus, Never> {
        authorizationStatusValue.eraseToAnyPublisher()
    }
}

extension HMCharacteristic {
    func writeValue(value: Any?) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in

            self.writeValue(value) { error in

                if let error = error {
                    promise(.failure(error))
                    return
                }

                promise(.success(()))
            }

        }.eraseToAnyPublisher()
    }
}

// MARK: - HMHomeManagerDelegate

extension HomeKitAccess: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ homeManager: HMHomeManager) {
        os_log("homeManagerDidUpdateHomes",
               log: log,
               type: .info)

        homeKitAccessoryDelegate.removeAll() // Make sure existing delegate have been removed. Repopulating

        var roomsWithLights = Rooms()

        defer {
            DispatchQueue.main.async {
                self.roomsCurrentValueSubject.value = roomsWithLights
            }
        }

        guard let primaryHome = homeManager.primaryHome else {
            os_log("Primary home not found",
                   log: Log.homeKitAccess,
                   type: .debug)
            return
        }

        roomsWithLights = primaryHome.rooms.map { $0.toRoom(homeKitAccessoryDelegates: self.homeKitAccessoryDelegate) }
            .filter { !$0.lights.isEmpty }
    }

    func homeManager(_: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        authorizationStatusValue.value = status
    }
}
