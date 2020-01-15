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
    var charastericToUpdate: String { get }
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

    func charastericsToUpdate(_ room: HMRoom) -> [HMCharacteristic] {
        room.characteristicsOfType(charastericToUpdate)
    }

    func update() -> AnyPublisher<Void, Error> {
        guard let hmRoom = self.hmRoom,
            let value = self.value else {
            return failHomeNotFound
        }

        os_log("Updating charastic %s for room %s",
               log: log,
               type: .info,
               charastericToUpdate,
               room.name)

        let allCompletedOperation = BaseOperation()

        let charastics = charastericsToUpdate(hmRoom)

        var operations: [BaseOperation] = charastics.map { (charastic) -> CharasticWriteOperation in
            let charasticOperation = CharasticWriteOperation(characteristic: charastic,
                                                             value: value)
            allCompletedOperation.addDependency(charasticOperation)
            return charasticOperation
        }

        operations.append(allCompletedOperation)

        return Future<Void, Error> { promise in

            let spid = OSSignpostID(log: self.log)
            let signpostName: StaticString = "Update Lights"

            allCompletedOperation.completionBlock = {
                os_signpost(.end,
                            log: self.log,
                            name: signpostName,
                            signpostID: spid,
                            "Finished updating lights charastic %s in room %s",
                            self.charastericToUpdate,
                            self.room.name)

                if let error = allCompletedOperation.firstDependencyError {
                    os_log("Error was encountered updating lights: %s",
                           log: self.log,
                           type: .error,
                           error.localizedDescription)

                    promise(.failure(error))
                } else {
                    os_log("Success updateing lights in room: %s",
                           log: self.log,
                           type: .info,
                           self.room.name)

                    promise(.success(()))
                }
            }

            os_signpost(.begin,
                        log: self.log,
                        name: signpostName,
                        signpostID: spid,
                        "Update charastic %s for room %s",
                        self.charastericToUpdate,
                        self.room.name)

            os_log("Starting update",
                   log: self.log,
                   type: .info)

            self.operationQueue.addOperations(operations, waitUntilFinished: false)
        }.eraseToAnyPublisher()
    }
}
