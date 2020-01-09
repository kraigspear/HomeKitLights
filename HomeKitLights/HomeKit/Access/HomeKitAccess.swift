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

/// Errors that can occure when accessing HomeKit
enum HomeKitAccessError: Error {
    /// There isn't a home associated with this account / device
    /// Nothing can happen.
    /// A good course of action would be to inform the user how to setup HomeKit
    case homeNotFound
}

/// Access to HomeKit data
protocol HomeKitAccessible {
    /// HomeKit rooms associtated with this account / device
    /// - Remarks: Only rooms for the first home is returned. Multiple homes are not supported.
    var rooms: AnyPublisher<[Room], HomeKitAccessError> { get }
}

/**
 Convert HomeKit objects from `HMHomeManager` to App Specific model objects.
 */
final class HomeKitAccess: NSObject, HomeKitAccessible {
    // MARK: - Members

    private let log = Log.homeKitAccess

    /// Manager used to access home kit
    private let homeKitHomeManager = HMHomeManager()

    // MARK: - Init

    override init() {
        super.init()
        homeKitHomeManager.delegate = self
    }

    // MARK: - Rooms

    /// Rooms subject. Set when rooms have been loaded
    private let roomsCurrentValueSubject = CurrentValueSubject<[Room], HomeKitAccessError>([])

    /// HomeKit rooms associtated with this account / device
    /// - Remarks: Only rooms for the first home is returned. Multiple homes are not supported.
    var rooms: AnyPublisher<[Room], HomeKitAccessError> {
        roomsCurrentValueSubject.eraseToAnyPublisher()
    }

    // MARK: - Loading

    private func reload() {
        guard let firstHome = homeKitHomeManager.homes.first else {
            return
        }

        roomsCurrentValueSubject.value = firstHome.rooms.map { $0.toRoom() }
    }
}

// MARK: - HMHomeManagerDelegate

extension HomeKitAccess: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_: HMHomeManager) {
        reload()
    }
}

// MARK: - HomeKit Extensions

extension HMRoom {
    func toRoom() -> Room {
        let accessories = self.accessories.map { $0.toAccessory() }

        return Room(name: name,
                    id: uniqueIdentifier,
                    accessories: accessories)
    }
}

extension HMAccessory {
    func toAccessory() -> Accessory {
        return Accessory(name: name,
                         id: uniqueIdentifier)
    }
}
