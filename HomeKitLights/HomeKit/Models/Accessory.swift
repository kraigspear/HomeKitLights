//
//  Accessory.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/9/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation

/// Represents an Accessory from HomeKit
struct Accessory: Identifiable, Hashable {
    let name: String
    let id: UUID
    let isOn: Bool
    let brightness: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AccessoryMock {
    static func light1() -> Accessory {
        Accessory(name: "light1",
                  id: UUID(uuidString: "C9C9BC8E-1F6F-458D-BAF4-99722786805D")!,
                  isOn: true,
                  brightness: 1)
    }

    static func light2() -> Accessory {
        Accessory(name: "light2", id: UUID(uuidString: "D23A4FED-9415-4F7E-BCA3-6A850398E557")!,
                  isOn: false,
                  brightness: 1)
    }

    static func light3() -> Accessory {
        Accessory(name: "light3", id: UUID(uuidString: "72141C0C-767A-4781-9BAC-BC767BD010D9")!,
                  isOn: false,
                  brightness: 1)
    }

    static func light4() -> Accessory {
        Accessory(name: "light4", id: UUID(uuidString: "129CFD34-B03F-44B1-A4CC-9DFB0924BB5D")!,
                  isOn: true,
                  brightness: 1)
    }
}
