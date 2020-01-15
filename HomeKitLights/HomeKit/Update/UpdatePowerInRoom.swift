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

final class UpdatePowerInRoom: RoomUpdatable {
    let operationQueue: OperationQueue
    let homeKitHomeManager: HMHomeManager
    let room: Room

    var charastericToUpdate: String {
        HMCharacteristicTypePowerState
    }

    init(room: Room,
         homeKitHomeManager: HMHomeManager,
         operationQueue: OperationQueue) {
        self.room = room
        self.homeKitHomeManager = homeKitHomeManager
        self.operationQueue = operationQueue
    }

    var value: Any? {
        guard let hmRoom = self.hmRoom else { return nil }
        var lightsAreOn = hmRoom.lightsAreOn
        lightsAreOn.toggle()
        return lightsAreOn
    }
}
