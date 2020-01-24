//
//  UpdateBrightnessInRoom.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import HomeKit

/**
 Updates the brightness level in a room

 - SeeAlso: `HomeKitAccess`

 ```swift
 func updateBrightness(_ brightness: Int,
                       forRoom room: Room) -> AnyPublisher<Void, Error> {
     UpdateBrightnessInRoom(room: room,
                            brightness: brightness,
                            homeKitHomeManager: homeKitHomeManager,
                            operationQueue: updateHomeKitQueue).update().eraseToAnyPublisher()
 }
 ```

 */
final class UpdateBrightnessInRoom: RoomUpdatable {
    /// Queue to run update on
    let operationQueue: OperationQueue

    /// Manager that is used to update
    let homeKitHomeManager: HMHomeManager

    /// Room being updated
    let room: Room

    /// Brightness leve to update to
    private let brightness: Int

    /// Indicates brightness to `RoomUpdatable`
    var characteristicToUpdate: String {
        HMCharacteristicTypeBrightness
    }

    /// Value to set.
    var value: Any? { brightness }

    /// Initialize a new UpdateBrightnessInRoom with dependencies
    /// - Parameters:
    ///   - room: Room being updated
    ///   - brightness: Brightness level to set to
    ///   - homeKitHomeManager: HomeKit manager to dothe update
    ///   - operationQueue: Queue to update on
    init(room: Room,
         brightness: Int,
         homeKitHomeManager: HMHomeManager,
         operationQueue: OperationQueue) {
        self.room = room
        self.brightness = brightness
        self.homeKitHomeManager = homeKitHomeManager
        self.operationQueue = operationQueue
    }
}
