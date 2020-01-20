//
//  Accessory.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/9/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation

/// Struc representation of an `HMAccessory` from HomeKit
/// - SeeAlso: `HMAccessory`
struct Accessory: Identifiable {
    /// Name of accessory
    let name: String

    /// UUID identifying this Accessory
    let id: UUID
    /// Is this Accessory on/off
    let isOn: Bool

    /// Brightness level for this Accessory
    let brightness: Int
}

extension Accessory: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AccessoryMock {
    static func light1() -> Light {
        Light(name: "light1",
              id: UUID(uuidString: "C9C9BC8E-1F6F-458D-BAF4-99722786805D")!,
              isOn: true,
              brightness: 95)
    }

    static func light2() -> Light {
        Light(name: "light2", id: UUID(uuidString: "D23A4FED-9415-4F7E-BCA3-6A850398E557")!,
              isOn: false,
              brightness: 50)
    }

    static func light3() -> Light {
        Light(name: "light3", id: UUID(uuidString: "72141C0C-767A-4781-9BAC-BC767BD010D9")!,
              isOn: false,
              brightness: 10)
    }

    static func light4() -> Light {
        Light(name: "light4", id: UUID(uuidString: "129CFD34-B03F-44B1-A4CC-9DFB0924BB5D")!,
              isOn: true,
              brightness: 100)
    }

    static func lightNoBrightness() -> Light {
        Light(name: "not bright", id: UUID(uuidString: "72DA99E8-C144-4C12-99C8-5EC0A9526A73")!,
              isOn: false,
              brightness: 50)
    }

    static func lightThatIsOn() -> Light {
        Light(name: "Some Light", id: UUID(uuidString: "67ACA76F-2BD8-477C-A02E-2D8E5F202AA8")!,
              isOn: true,
              brightness: 50)
    }

    static func lightThatIsOff() -> Light {
        Light(name: "Some Light", id: UUID(uuidString: "31D60833-62D2-4BDA-B028-A8CFDA4138D2")!,
              isOn: false,
              brightness: 50)
    }
}
