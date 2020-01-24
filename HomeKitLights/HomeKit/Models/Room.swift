//
//  Room.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import HomeKit

typealias Rooms = [Room]

/// Struct representation of `HMRoom`
/// - SeeAlso: `Light`
/// - SeeAlso: `RoomView`
/// - SeeAlso: `RoomViewModel`
/// - SeeAlso: `HMRoom`
struct Room: Identifiable {
    /// The name of the Room
    let name: String
    /// UUID for this room
    let id: UUID
    /// Lights that belong to this Room
    let lights: Lights

    /// Is this room reachable.
    let isReachable: Bool

    /// The highest brightness value
    var maxBrightness: Int {
        lights.max(by: { $0.brightness < $1.brightness })?.brightness ?? 0
    }

    /// True if there are any lights on in this room
    var areAnyLightsOn: Bool {
        lights.any(itemsAre: { $0.isOn })
    }
}

extension Room: Hashable {
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter: hasher
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/**
 * Mock room conforming to `RoomProtocol` that can be used in both
 * Unit Test & SwiftUI previews
 */
struct RoomMock {
    static func livingRoom() -> Room {
        let accessory1 = AccessoryMock.light1()
        return Room(name: "Living Room",
                    id: UUID(uuidString: "46A68B10-0E92-4821-91A0-0D11926F284D")!,
                    lights: [accessory1],
                    isReachable: true)
    }

    static func notReachable() -> Room {
        let accessory1 = AccessoryMock.light1()
        return Room(name: "Living Room",
                    id: UUID(uuidString: "46A68B10-0E92-4821-91A0-0D11926F284D")!,
                    lights: [accessory1],
                    isReachable: false)
    }

    static func diningRoom() -> Room {
        let accessory1 = AccessoryMock.light1()
        let accessory2 = AccessoryMock.light2()

        return Room(name: "Dining Room",
                    id: UUID(uuidString: "4B3C5FE2-1EA4-4764-AD36-CFE506A43606")!,
                    lights: [accessory1, accessory2],
                    isReachable: true)
    }

    static func kitchen() -> Room {
        let accessory1 = AccessoryMock.light1()
        let accessory2 = AccessoryMock.light2()
        let accessory3 = AccessoryMock.light3()
        let accessory4 = AccessoryMock.light4()

        return Room(name: "Kitchen",
                    id: UUID(uuidString: "65F06C57-5191-45B8-BF78-9BBD922032A6")!,
                    lights: [accessory1, accessory2, accessory3, accessory4],
                    isReachable: true)
    }

    static func roomNoBrightness() -> Room {
        let notBright = AccessoryMock.lightNoBrightness()
        return Room(name: "Not bright",
                    id: UUID(uuidString: "F584E2C9-2645-45F1-8B82-EAB38A18D0EB")!,
                    lights: [notBright],
                    isReachable: true)
    }

    static func roomWithLightOn() -> Room {
        Room(name: "Room that is on",
             id: UUID(uuidString: "C21B4028-730F-4EEB-9694-58135E67ADF2")!,
             lights: [AccessoryMock.lightThatIsOn()],
             isReachable: true)
    }

    static func roomWithLightOff() -> Room {
        Room(name: "Room that is Off",
             id: UUID(uuidString: "5698437D-A75A-4F51-AD10-7B29680B538C")!,
             lights: [AccessoryMock.lightThatIsOff()],
             isReachable: true)
    }

    static func rooms() -> Rooms {
        [livingRoom(),
         diningRoom(),
         kitchen()]
    }
}
