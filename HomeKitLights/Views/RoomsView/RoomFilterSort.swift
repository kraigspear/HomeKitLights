//
//  RoomFilterSort.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/15/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import os.log

/// Sort filter a list of rooms
/// - SeeAlso: `RoomsViewModel`
protocol RoomFilterSortable {
    /// Apply a sort / filter combination on an array of rooms
    /// - Parameters:
    ///   - filter: What filter should be applied
    ///   - sort: What sort should applied
    ///   - rooms: Rooms to sort / filter
    ///   - returns: Sorted / Filter array of rooms.
    ///
    /// ```swift
    ///
    ///    let filter = RoomFilter(rawValue: filterIndex)!
    ///    let sort = RoomSort(rawValue: sortIndex)!
    ///
    ///    rooms = roomFilterSortable.apply(filter: filter,
    ///                                     sort: sort,
    ///                                     on: allRooms)
    /// ```
    func apply(filter: RoomFilter,
               sort: RoomSort,
               on rooms: [Room]) -> [Room]
}

final class RoomFilterSortMock: RoomFilterSortable {
    private(set) var appliedCount = 0

    func apply(filter _: RoomFilter,
               sort _: RoomSort,
               on rooms: [Room]) -> [Room] {
        appliedCount += 1
        return rooms
    }
}

/// Filters & Sorts rooms in the UI.
final class RoomFilterSort: RoomFilterSortable {
    private let log = Log.homeKitAccess

    // MARK: - Members

    /// Access to rooms data, last used date/time
    private let roomDataAccessible: RoomDataAccessible

    // MARK: - Init

    /// Initilize with requried member(s)
    /// - Parameter roomDataAccessible: Access to rooms data, last used date/time
    init(roomDataAccessible: RoomDataAccessible) {
        self.roomDataAccessible = roomDataAccessible
    }

    convenience init() {
        self.init(roomDataAccessible: RoomAccessor.sharedAccessor)
    }

    /// Apply a sort / filter combination on an array of rooms
    /// - Parameters:
    ///   - filter: What filter should be applied
    ///   - sort: What sort should applied
    ///   - rooms: Rooms to sort / filter
    ///   - returns: Sorted / Filter array of rooms.
    func apply(filter: RoomFilter,
               sort: RoomSort,
               on rooms: [Room]) -> [Room] {
        os_log("applySortFilter",
               log: Log.homeKitAccess,
               type: .debug)

        var filtered = rooms.filter(by: filter)
        filtered.sortByName()

        if sort == .alphabetical { return filtered }

        let lastAccessedRooms = roomDataAccessible.fetchLastAccessedRooms()

        struct RoomLastAccessed {
            let room: Room
            let dateLastAccessed: Date
        }

        var roomsLastAccessed = filtered.map { room -> RoomLastAccessed in
            let lastAccessed = lastAccessedRooms[room.id] ?? Date(timeIntervalSince1970: 0)
            return RoomLastAccessed(room: room, dateLastAccessed: lastAccessed)
        }

        roomsLastAccessed.sort { $0.dateLastAccessed > $1.dateLastAccessed }
        return roomsLastAccessed.map { $0.room }
    }
}

private extension Array where Element == Room {
    /// Filter lights by filter passed in
    /// - Parameter filter: What to filter on
    func filter(by filter: RoomFilter) -> [Room] {
        switch filter {
        case .all:
            return self
        case .off:
            return self.filter { $0.lights.any(itemsAre: { !$0.isOn }) }
        case .on:
            return self.filter { $0.lights.any(itemsAre: { $0.isOn }) }
        }
    }

    /// Sort rooms by their names
    mutating func sortByName() {
        sort { $0.name < $1.name }
    }
}
