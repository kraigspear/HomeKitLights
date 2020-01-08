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
protocol RoomProtocol: HomeKitModel {}

/// Represents a Room from HomeKit
struct Room: RoomProtocol {
    /// Inner room from HomeKit
    private let homeKitRoom: HMRoom

    /// Initialize a new room from a `HMRoom`
    /// - Parameter homeKitRoom: `HMRoom` that is being abstracted
    init(homeKitRoom: HMRoom) {
        self.homeKitRoom = homeKitRoom
    }

    /// The unique identifier for a room.
    var uniqueIdentifier: UUID { homeKitRoom.uniqueIdentifier }

    /// The name of the room.
    var name: String { homeKitRoom.name }
}

/**
 * Mock room conforming to `RoomProtocol` that can be used in both
 * Unit Test & SwiftUI previews
 */
struct RoomMock: RoomProtocol {
    let name: String
    let uniqueIdentifier: UUID

    init(name: String,
         uniqueIdentifier: UUID) {
        self.name = name
        self.uniqueIdentifier = uniqueIdentifier
    }

    static func livingRoom() -> RoomMock {
        RoomMock(name: "Living Room", uniqueIdentifier: UUID(uuidString: "46A68B10-0E92-4821-91A0-0D11926F284D")!)
    }

    static func diningRooom() -> RoomMock {
        RoomMock(name: "Dining Room", uniqueIdentifier: UUID(uuidString: "4B3C5FE2-1EA4-4764-AD36-CFE506A43606")!)
    }

    static func kitchen() -> RoomMock {
        RoomMock(name: "Kitchen", uniqueIdentifier: UUID(uuidString: "4B3C5FE2-1EA4-4764-AD36-CFE506A43606")!)
    }

    static func rooms() -> [RoomMock] {
        return [livingRoom(),
                diningRooom(),
                kitchen()]
    }
}
