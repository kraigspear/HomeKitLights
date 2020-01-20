//
//  RoomFilterSortTest.swift
//  HomeKitLightsTests
//
//  Created by Kraig Spear on 1/15/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

@testable import HomeKitLights
import XCTest

final class RoomFilterSortTest: XCTestCase {
    private var roomDataAccessibleMock: RoomDataAccessibleMock!
    private var sut: RoomFilterSort!

    override func setUp() {
        roomDataAccessibleMock = RoomDataAccessibleMock()
        sut = RoomFilterSort(roomDataAccessible: roomDataAccessibleMock)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOnlyRoomsThatAreOnWhenFilterIsOn() {
        let roomOn = RoomMock.roomWithLightOn()
        let roomOff = RoomMock.roomWithLightOff()

        let rooms = sut.apply(filter: RoomFilter.on,
                              sort: .alphabetical,
                              on: [roomOn, roomOff])

        XCTAssertEqual(1, rooms.count)

        XCTAssertTrue(rooms[0].lights[0].isOn)
    }

    func testOnlyRoomsThatAreOffWhenFilterIsOff() {
        let roomOn = RoomMock.roomWithLightOn()
        let roomOff = RoomMock.roomWithLightOff()

        let rooms = sut.apply(filter: RoomFilter.off,
                              sort: .alphabetical,
                              on: [roomOn, roomOff])

        XCTAssertEqual(1, rooms.count)

        XCTAssertFalse(rooms[0].lights[0].isOn)
    }

    func testSortOrderIsAlphabetical() {
        let room1 = Room(name: "Zed Light",
                         id: UUID(uuidString: "89435E47-026F-42ED-92CB-B7EE1A05AB5E")!,
                         lights: [AccessoryMock.lightThatIsOn()])

        let room2 = Room(name: "A light",
                         id: UUID(uuidString: "287329CC-E04D-45BC-B9C8-42729A1B2103")!,
                         lights: [AccessoryMock.lightThatIsOn()])

        let rooms = sut.apply(filter: RoomFilter.all,
                              sort: .alphabetical,
                              on: [room1, room2])

        XCTAssertEqual(rooms[0].name, "A light")
        XCTAssertEqual(rooms[1].name, "Zed Light")
    }

    func testLastAccessedIsFirstWhenSortIsLastAccessed() {
        let id1 = UUID(uuidString: "0D3C0023-CF34-4498-9553-E765353C5D75")!
        let id2 = UUID(uuidString: "5C0EDF84-FEFF-42A9-8F6D-4635552DD3D4")!

        let room1 = Room(name: "Breakfast Nook",
                         id: id1,
                         lights: [AccessoryMock.lightThatIsOn()])

        let room2 = Room(name: "Hallway",
                         id: id2,
                         lights: [AccessoryMock.lightThatIsOn()])

        let dateNow = Date()

        var dayComponent = DateComponents()
        dayComponent.hour = -1
        let calendar = Calendar.current
        let anHourAgo = calendar.date(byAdding: dayComponent, to: dateNow)

        roomDataAccessibleMock.lastAccessedRoomsValue[id1] = anHourAgo
        roomDataAccessibleMock.lastAccessedRoomsValue[id2] = dateNow

        let rooms = sut.apply(filter: RoomFilter.all,
                              sort: .lastUpdated,
                              on: [room1, room2])

        XCTAssertEqual(rooms[0].id, id2)
        XCTAssertEqual(rooms[1].id, id1)
    }
}
