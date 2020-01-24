//
//  UpdatePowerInRoom.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import HomeKit

/**

 Update power (on/off) in a room

 - SeeAlso: `HomeKitAccess`

 ```swift
 func toggle(_ room: Room) -> AnyPublisher<Void, Error> {
     UpdatePowerInRoom(room: room,
                       homeKitHomeManager: homeKitHomeManager,
                       operationQueue: updateHomeKitQueue).update().eraseToAnyPublisher()
 }
 ```

 */
final class UpdatePowerInRoom: RoomUpdatable {
    /// Queue to update on
    let operationQueue: OperationQueue
    /// Access to HomeKit
    let homeKitHomeManager: HMHomeManager
    /// Room being updated
    let room: Room

    /// Indicates that power is to be updated
    var characteristicToUpdate: String {
        HMCharacteristicTypePowerState
    }

    /// Initialize a new UpdatePowerInRoom with dependencies
    /// - Parameters:
    ///   - room: Room being updated
    ///   - homeKitHomeManager: HomeKit manager to dothe update
    ///   - operationQueue: Queue to update on
    init(room: Room,
         homeKitHomeManager: HMHomeManager,
         operationQueue: OperationQueue) {
        self.room = room
        self.homeKitHomeManager = homeKitHomeManager
        self.operationQueue = operationQueue
    }

    /// Value to set.
    var value: Any? {
        guard let hmRoom = self.hmRoom else { return nil }
        var lightsAreOn = hmRoom.lightsAreOn
        lightsAreOn.toggle()
        return lightsAreOn
    }
}
