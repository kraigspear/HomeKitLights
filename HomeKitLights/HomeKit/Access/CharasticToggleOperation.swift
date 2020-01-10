//
//  CharasticToggleOperation.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import HomeKit

final class CharasticToggleOperation: BaseOperation {
    private let characteristic: HMCharacteristic
    private let turnOn: Bool

    init(characteristic: HMCharacteristic,
         turnOn: Bool) {
        self.characteristic = characteristic
        self.turnOn = turnOn
    }

    override func main() {
        characteristic.writeValue(turnOn) { error in
            super.error = error
            self.done()
        }
    }
}
