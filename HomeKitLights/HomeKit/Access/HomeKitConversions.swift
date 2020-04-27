//
//  HomeKitExtensions.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import HomeKit
import os.log

extension HMRoom {
    /// Covert this `HMRoom` to a `Room`
    func toRoom(homeKitAccessoryDelegates: HomeKitAccessoryDelegates) -> Room {
        let lightAccessories = accessories.filter { $0.isLight }
            .map { $0.toAccessory(homeKitAccessoryDelegates: homeKitAccessoryDelegates) }

        let room = Room(name: name,
                        id: uniqueIdentifier,
                        lights: lightAccessories,
                        isReachable: isReachable)

        return room
    }
}

extension HMCharacteristic {
    /// Reading value of `HMCharacteristic` as Bool, or defaulting to false
    var isOn: Bool {
        assert(value is Bool, "Expect Bool")
        return value as? Bool ?? false
    }
}

extension HMAccessory {
    /// Find the lightbulb service for this HMAccessory
    private var lightBulbService: HMService? {
        services.first(where: { $0.serviceType == HMServiceTypeLightbulb })
    }

    /// Finds the `HMCharacteristic` that is a `HMServiceTypeLightbulb`
    /// and contains a power state.
    var lightBulbCharacteristic: HMCharacteristic? {
        lightBulbService?.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState && $0.value is Bool })
    }

    /// Characteristic matching brightness, or nil
    var brightnessCharacteristic: HMCharacteristic? {
        lightBulbService?.characteristics.first { $0.characteristicType == HMCharacteristicTypeBrightness }
    }

    /// Is the power state for this `HMAccessory` on
    var isOn: Bool {
        lightBulbCharacteristic?.value as? Bool ?? false
    }

    /// Is this `HMAccessory` a light?
    var isLight: Bool {
        lightBulbService != nil
    }

    /// Brightness value for this `HMAccessory` or 1 if brightness not found.
    var brightness: Int {
        brightnessCharacteristic?.value as? Int ?? 1
    }

    /// Converts this `HMAccessory` to a `Accessory`
    func toAccessory(homeKitAccessoryDelegates: HomeKitAccessoryDelegates) -> Accessory {
        // This will notify calling code of state changes to the accessory (on / off, brightness)
        homeKitAccessoryDelegates.append(self)

        return Accessory(name: name,
                         id: uniqueIdentifier,
                         isOn: isOn,
                         brightness: brightness)
    }
}

extension HMRoom {
    var isReachable: Bool {
        !(powerStateCharacteristics.any { $0.value == nil })
    }

    /// Are the lights in this room on?
    /// Considered on or off for greater amount of lights that are off / on
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

    /// Characteristics that are the power state (HMCharacteristicTypePowerState)
    var powerStateCharacteristics: [HMCharacteristic] {
        characteristicsOfType(HMCharacteristicTypePowerState)
    }
}

extension HMRoom {
    /// HMService' that are considered
    var lightBulbServices: [HMService] {
        let lightBulbServices = accessories.reduce([]) { (result, element) -> [HMService] in
            result + element.services
        }.filter { $0.serviceType == HMServiceTypeLightbulb }
        return lightBulbServices
    }

    /// Finds all `HMCharacteristic` matching a type
    /// - Parameter type: Type to match. Should be one of the HMCharacteristicType(s)
    func characteristicsOfType(_ type: String) -> [HMCharacteristic] {
        lightBulbServices.compactMap { $0.characteristics.first(where: { $0.characteristicType == type }) }
    }
}
