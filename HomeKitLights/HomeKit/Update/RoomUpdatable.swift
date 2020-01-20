//
//  RoomUpdatable.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import HomeKit
import os.log

protocol RoomUpdatable {
    var homeKitHomeManager: HMHomeManager { get }
    var characteristicToUpdate: String { get }
    var value: Any? { get }
    var room: Room { get }
    var operationQueue: OperationQueue { get }
}

extension RoomUpdatable {
    var log: OSLog { Log.homeKitAccess }

    var hmRoom: HMRoom? {
        guard let firstHome = homeKitHomeManager.homes.first else {
            assertionFailure("Finding room, but no home setup?")
            return nil
        }
        return firstHome.rooms.first(where: { $0.uniqueIdentifier == room.id })
    }

    var failHomeNotFound: AnyPublisher<Void, Error> {
        Fail<Void, Error>(error: HomeKitAccessError.homeNotFound).eraseToAnyPublisher()
    }

    func characteristicToUpdate(_ room: HMRoom) -> [HMCharacteristic] {
        room.characteristicsOfType(characteristicToUpdate)
    }

    func update() -> AnyPublisher<Void, Error> {
        guard let hmRoom = self.hmRoom,
            let value = self.value else {
            return failHomeNotFound
        }

        os_log("Updating characteristic %s for room %s",
               log: log,
               type: .info,
               characteristicToUpdate,
               room.name)

        let allCompletedOperation = BaseOperation()

        let characteristics = characteristicToUpdate(hmRoom)

        var operations: [BaseOperation] = characteristics.map { (characteristic) -> CharacteristicWriteOperation in
            let characteristicOperation = CharacteristicWriteOperation(characteristic: characteristic,
                                                                       value: value)
            allCompletedOperation.addDependency(characteristicOperation)
            return characteristicOperation
        }

        operations.append(allCompletedOperation)

        return Future<Void, Error> { promise in

            let signPostId = OSSignpostID(log: self.log)
            let signpostName: StaticString = "Update Lights"

            allCompletedOperation.completionBlock = {
                os_signpost(.end,
                            log: self.log,
                            name: signpostName,
                            signpostID: signPostId,
                            "Finished updating lights characteristic %s in room %s",
                            self.characteristicToUpdate,
                            self.room.name)

                if let error = allCompletedOperation.firstDependencyError {
                    os_log("Error was encountered updating lights: %s",
                           log: self.log,
                           type: .error,
                           error.localizedDescription)

                    promise(.failure(error))
                } else {
                    os_log("Success updating lights in room: %s",
                           log: self.log,
                           type: .info,
                           self.room.name)

                    promise(.success(()))
                }
            }

            os_signpost(.begin,
                        log: self.log,
                        name: signpostName,
                        signpostID: signPostId,
                        "Update characteristic %s for room %s",
                        self.characteristicToUpdate,
                        self.room.name)

            os_log("Starting update",
                   log: self.log,
                   type: .info)

            self.operationQueue.addOperations(operations, waitUntilFinished: false)
        }.eraseToAnyPublisher()
    }
}
