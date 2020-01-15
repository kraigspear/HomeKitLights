//
//  CharasticToggleOperation.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import HomeKit

/// Wrap writing to a `HMCharacteristic`
final class CharasticWriteOperation: BaseOperation {
    private let characteristic: HMCharacteristic
    private let value: Any

    init(characteristic: HMCharacteristic,
         value: Any) {
        self.characteristic = characteristic
        self.value = value
    }

    override func main() {
        characteristic.writeValue(value) { error in
            super.error = error
            self.done()
        }
    }
}
