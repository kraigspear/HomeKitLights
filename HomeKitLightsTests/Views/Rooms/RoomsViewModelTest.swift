//
//  RoomsViewModelTest.swift
//  LightsViewModelTest
//
//  eCreated by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
@testable import HomeKitLights
import XCTest

final class RoomsViewModelTest: XCTestCase {
    // MARK: - Dependencies

    private var homeKitAccessibleMock: HomeKitAccessMock!
    private var roomDataAccessibleMock: RoomDatabaseAccessorMock!
    private var refreshNotificationMock: RefreshNotificationMock!
    private var roomSortMock: RoomFilterSortMock!

    // MARK: - Subject under test

    private var sut: RoomsViewModel!

    // MARK: - Lifecycle

    override func setUp() {
        homeKitAccessibleMock = HomeKitAccessMock()
        homeKitAccessibleMock.whenHasRooms()
        roomDataAccessibleMock = RoomDatabaseAccessorMock()
        refreshNotificationMock = RefreshNotificationMock()
        roomSortMock = RoomFilterSortMock()
        sut = RoomsViewModel(homeKitAccessible: homeKitAccessibleMock,
                             roomDataAccessible: roomDataAccessibleMock,
                             roomFilterSortable: roomSortMock,
                             refreshNotification: refreshNotificationMock,
                             urlOpener: URLOpener())
    }

    override func tearDown() {
        roomsSinkCancel = nil
    }

    // MARK: - Test

    private var roomsSinkCancel: AnyCancellable?
    func testRoomsAreLoadedWhenViewAppears() {
        homeKitAccessibleMock.whenHasRooms()

        let expectRooms = expectation(description: "rooms")

        roomsSinkCancel = sut.$rooms.sink { rooms in
            if rooms.count > 0 {
                expectRooms.fulfill()
            }
        }

        sut.onAppear()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectRooms], timeout: 1))
    }

    // MARK: - Refresh Notifification

    func testDataIsReloadedWhenRefreshNotifiactionNotifies() {
        homeKitAccessibleMock.whenHasRooms()

        let expectRooms = expectation(description: "rooms")

        roomsSinkCancel = sut.$rooms.sink { rooms in
            if rooms.count > 0 {
                expectRooms.fulfill()
            }
        }

        refreshNotificationMock.whenNotificationPosted()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectRooms], timeout: 1))
    }

    // MARK: - Empty State

    func testEmptyStateIsShownWhenThereAreNoRooms() {
        homeKitAccessibleMock.whenThereAreNoRooms()
        sut.onAppear()
        XCTAssertTrue(sut.isEmptyStateVisible)
    }

    func testEmptyStateIsHiddenWhenThereAreRooms() {
        homeKitAccessibleMock.whenHasRooms()

        let expectRooms = expectation(description: "rooms")

        roomsSinkCancel = sut.$rooms.sink { rooms in
            if rooms.count > 0 {
                expectRooms.fulfill()
            }
        }

        sut.onAppear()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectRooms], timeout: 1))
        XCTAssertFalse(sut.isEmptyStateVisible)
    }

    // MARK: - Filter Button

    func testFilterButtonIsFilledWhenShowingFilter() {
        sut.isShowingSortFilter = true
        XCTAssertEqual(RoomsViewModel.FilterButtonImageFilled, sut.filterButtonImage)
    }

    func testFilterButtonOutlineWhenNotShowingFilter() {
        sut.isShowingSortFilter = false
        XCTAssertEqual(RoomsViewModel.FilterButtonImage, sut.filterButtonImage)
    }

    // MARK: - Apply Filter

    func testSortFilterIsAppliedWhenFilterIndexChanges() {
        homeKitAccessibleMock.whenHasOneRoomOnAndOneRoomOff()

        let expectRooms = expectation(description: "dataLoaded")

        roomsSinkCancel = sut.$rooms.sink { rooms in
            if rooms.count > 0 {
                expectRooms.fulfill()
            }
        }

        sut.onAppear()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectRooms], timeout: 1))

        roomsSinkCancel = nil

        XCTAssertEqual(1, roomSortMock.appliedCount) // Initial load
        sut.filterIndex = 0
        XCTAssertEqual(2, roomSortMock.appliedCount)
        sut.sortIndex = 1
        XCTAssertEqual(3, roomSortMock.appliedCount)
    }

    // MARK: - Filter button

    // What happens when the toggle button is tapped
    func testIsShowingFilterToggledWhenShowingFilterToggled() {
        XCTAssertFalse(sut.isShowingSortFilter)
        sut.toggleShowingFilter()
        XCTAssertTrue(sut.isShowingSortFilter)
    }

    // MARK: - Room Data Updated

    // The data in the data store (core data) has changed. Since this is
    // can reflect what is being displayed, data needs to reload
    func testHomeKitReloadedWhenRoomDataUpdated() {
        XCTAssertEqual(0, homeKitAccessibleMock.reloadCalled)
        roomDataAccessibleMock.sendRoomDataUpdated()
        XCTAssertEqual(1, homeKitAccessibleMock.reloadCalled)
    }
}
