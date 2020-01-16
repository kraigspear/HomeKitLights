//
//  HomeKitExtensions.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import HomeKit

extension HMRoom {
    func toRoom() -> Room {
        let lightAccessories = accessories.filter { $0.isLight }
            .map { $0.toAccessory() }

        let room = Room(name: name,
                        id: uniqueIdentifier,
                        lights: lightAccessories)

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

    var isLight: Bool {
        lightBulbService != nil
    }

    var brightnessCharastic: HMCharacteristic? {
        lightBulbService?.characteristics.first { $0.characteristicType == HMCharacteristicTypeBrightness }
    }

    var brightness: Int {
        brightnessCharastic?.value as? Int ?? 1
    }

    func toAccessory() -> Accessory {
        Accessory(name: name,
                  id: uniqueIdentifier,
                  isOn: isOn,
                  brightness: brightness)
    }
}

extension HMRoom {
    var lightsAreOn: Bool {
        let characteristics = powerStateCharacteristics

        let countOn = characteristics.reduce(0) { (total, characteristic) -> Int in
            if characteristic.isOn {
                return total + 1
            } else {
                return total
            }
        }

        let countOff = characteristics.reduce(0) { (total, characteristic) -> Int in
            if characteristic.isOn {
                return total
            } else {
                return total + 1
            }
        }

        return countOn > countOff
    }

    var powerStateCharacteristics: [HMCharacteristic] {
        characteristicsOfType(HMCharacteristicTypePowerState)
    }
}

extension HMRoom {
    var lightBulbServices: [HMService] {
        let lightBulbServices = accessories.reduce([]) { (result, element) -> [HMService] in
            result + element.services
        }.filter { $0.serviceType == HMServiceTypeLightbulb }
        return lightBulbServices
    }

    func characteristicsOfType(_ type: String) -> [HMCharacteristic] {
        lightBulbServices.compactMap { $0.characteristics.first(where: { $0.characteristicType == type }) }
    }
}
