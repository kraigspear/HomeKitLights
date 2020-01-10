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

    /// Toggle on off state
    /// - Parameter room: Room to update
    func toggle(_ room: Room) -> AnyPublisher<Void, Error>
}

/**
 Convert HomeKit objects from `HMHomeManager` to App Specific model objects.
 */
final class HomeKitAccess: NSObject, HomeKitAccessible {
    // MARK: - Members

    private let log = Log.homeKitAccess

    /// Manager used to access home kit
    private let homeKitHomeManager = HMHomeManager()

    /// Queue to execute HomeKit operations on
    private let updateHomeKitQueue = OperationQueue()

    // MARK: - Init

    override init() {
        super.init()
        updateHomeKitQueue.maxConcurrentOperationCount = 5
        updateHomeKitQueue.qualityOfService = .userInitiated
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

        let rooms = firstHome.rooms.map { $0.toRoom() }

        DispatchQueue.main.async {
            self.roomsCurrentValueSubject.value = rooms
        }
    }

    /// Toggle off on state for a room
    /// - Parameter room: Room to toggle
    func toggle(_ room: Room) -> AnyPublisher<Void, Error> {
        os_log("Toggle: %s",
               log: log,
               type: .debug,
               room.name)

        // We only support 1 home.
        guard let firstHome = homeKitHomeManager.homes.first else {
            assertionFailure("Toggling rooom without a home?")
            return Fail<Void, Error>(error: HomeKitAccessError.homeNotFound).eraseToAnyPublisher()
        }

        guard let hmRoom = firstHome.rooms.first(where: { $0.uniqueIdentifier == room.id }) else {
            os_log("Room passed in not found. name: %s id: %s",
                   log: log,
                   type: .fault,
                   room.name,
                   room.id.description)

            assertionFailure("Room passed in doesn't exist")
            return Fail<Void, Error>(error: HomeKitAccessError.homeNotFound).eraseToAnyPublisher()
        }

        os_log("Found room: %s",
               log: Log.homeKitAccess,
               type: .debug,
               room.name)

        // Get an array of all lightbulb services in this room
        let lightBulbServices = hmRoom.accessories.reduce([]) { (result, element) -> [HMService] in
            result + element.services
        }.filter { $0.serviceType == HMServiceTypeLightbulb }

        os_log("Room has %d lightbulbs",
               log: Log.homeKitAccess,
               type: .debug,
               lightBulbServices.count)

        // Get an array of all charastics that have a power state (that is bool) for the
        // lightbulb services
        let charastics = lightBulbServices.compactMap { $0.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState && $0.value is Bool }) }

        let countOn = charastics.reduce(0) { (total, charastic) -> Int in
            if charastic.isOn {
                return total + 1
            } else {
                return total
            }
        }

        let countOff = charastics.reduce(0) { (total, charastic) -> Int in
            if charastic.isOn {
                return total
            } else {
                return total + 1
            }
        }

        let mostLightsOn = countOn > countOff
        // We want to toggle from the most used
        let turningOn = !mostLightsOn

        assert(lightBulbServices.count == charastics.count, "Lightbulbs without a powerstate?")

        os_log("Found %d charastics with a powerstate that is bool",
               log: Log.homeKitAccess,
               type: .debug,
               charastics.count)

        // Used to get notified when all operations have completed.
        let allCompletedOperation = BaseOperation()

        var operations: [BaseOperation] = charastics.map { (charastic) -> CharasticToggleOperation in
            let charasticOperation = CharasticToggleOperation(characteristic: charastic, turnOn: turningOn)
            allCompletedOperation.addDependency(charasticOperation)
            return charasticOperation
        }

        operations.append(allCompletedOperation)

        return Future<Void, Error> { promise in

            let spid = OSSignpostID(log: self.log)
            let signpostName: StaticString = "Toggle Lights"

            allCompletedOperation.completionBlock = {
                os_signpost(.end,
                            log: self.log,
                            name: signpostName,
                            signpostID: spid,
                            "Finished toggeling lights for: %s",
                            room.name)

                self.reload()

                if let error = allCompletedOperation.firstDependencyError {
                    os_log("Error was encontered toggeling lights: %s",
                           log: self.log,
                           type: .error,
                           error.localizedDescription)

                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }

            os_signpost(.begin,
                        log: self.log,
                        name: signpostName,
                        signpostID: spid,
                        "Toggle lights for: %s",
                        room.name)

            self.updateHomeKitQueue.addOperations(operations, waitUntilFinished: false)
        }.eraseToAnyPublisher()
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
    func homeManagerDidUpdateHomes(_: HMHomeManager) {
        reload()
    }
}

// MARK: - HomeKit Extensions

extension HMRoom {
    func toRoom() -> Room {
        let accessories = self.accessories.map { $0.toAccessory() }

        let room = Room(name: name,
                        id: uniqueIdentifier,
                        accessories: accessories)

        return room
    }
}

extension HMCharacteristic {
    var isOn: Bool {
        value as? Bool ?? false
    }
}

extension HMAccessory {
    private var lightBulbService: HMService? {
        services.first(where: { $0.serviceType == HMServiceTypeLightbulb })
    }

    private var lightBulbCharastic: HMCharacteristic? {
        lightBulbService?.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState && $0.value is Bool })
    }

    var isOn: Bool {
        lightBulbCharastic?.value as? Bool ?? false
    }

    func toAccessory() -> Accessory {
        return Accessory(name: name,
                         id: uniqueIdentifier,
                         isOn: isOn)
    }
}
