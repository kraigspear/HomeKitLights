//
//  UpdateBrightnessInRoom.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation

import Combine
import Foundation
import HomeKit

final class UpdateBrightnessInRoom: RoomUpdatable {
    let operationQueue: OperationQueue
    let homeKitHomeManager: HMHomeManager
    let room: Room
    private let brightness: Int

    var charastericToUpdate: String {
        HMCharacteristicTypeBrightness
    }

    init(room: Room,
         brightness: Int,
         homeKitHomeManager: HMHomeManager,
         operationQueue: OperationQueue) {
        self.room = room
        self.brightness = brightness
        self.homeKitHomeManager = homeKitHomeManager
        self.operationQueue = operationQueue
    }

    var value: Any? { brightness }
}
