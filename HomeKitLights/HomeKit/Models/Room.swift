//
//  Room.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import HomeKit

/// Represents a Room from HomeKit
struct Room: Identifiable, Hashable {
    let name: String
    let id: UUID
    let lights: Lights

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// The highest brightness value
    var maxBrightness: Int {
        lights.max(by: { $0.brightness < $1.brightness })?.brightness ?? 0
    }
}

typealias Rooms = [Room]

/**
 * Mock room conforming to `RoomProtocol` that can be used in both
 * Unit Test & SwiftUI previews
 */
struct RoomMock {
    static func livingRoom() -> Room {
        let accessory1 = AccessoryMock.light1()
        return Room(name: "Living Room",
                    id: UUID(uuidString: "46A68B10-0E92-4821-91A0-0D11926F284D")!,
                    lights: [accessory1])
    }

    static func diningRooom() -> Room {
        let accessory1 = AccessoryMock.light1()
        let accessory2 = AccessoryMock.light2()

        return Room(name: "Dining Room",
                    id: UUID(uuidString: "4B3C5FE2-1EA4-4764-AD36-CFE506A43606")!,
                    lights: [accessory1, accessory2])
    }

    static func kitchen() -> Room {
        let accessory1 = AccessoryMock.light1()
        let accessory2 = AccessoryMock.light2()
        let accessory3 = AccessoryMock.light3()
        let accessory4 = AccessoryMock.light4()

        return Room(name: "Kitchen",
                    id: UUID(uuidString: "65F06C57-5191-45B8-BF78-9BBD922032A6")!,
                    lights: [accessory1, accessory2, accessory3, accessory4])
    }

    static func rooms() -> [Room] {
        return [livingRoom(),
                diningRooom(),
                kitchen()]
    }
}
