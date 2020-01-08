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
        Room(name: "Living Room", id: UUID(uuidString: "46A68B10-0E92-4821-91A0-0D11926F284D")!)
    }

    static func diningRooom() -> Room {
        Room(name: "Dining Room", id: UUID(uuidString: "4B3C5FE2-1EA4-4764-AD36-CFE506A43606")!)
    }

    static func kitchen() -> Room {
        Room(name: "Kitchen", id: UUID(uuidString: "4B3C5FE2-1EA4-4764-AD36-CFE506A43606")!)
    }

    static func rooms() -> [Room] {
        return [livingRoom(),
                diningRooom(),
                kitchen()]
    }
}
