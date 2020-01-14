//
//  LightsViewModelTest.swift
//  LightsViewModelTest
//
//  eCreated by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
@testable import HomeKitLights
import XCTest

final class LightsViewModelTest: XCTestCase {
    // MARK: - Dependencies

    private var homeKitAccessibleMock: HomeKitAccessMock!
    private var roomDataAccessibleMock: RoomDataAccessibleMock!
    private var refreshNotificationMock: RefreshNotificationMock!

    // MARK: - Subject under test

    private var sut: RoomsViewModel!

    // MARK: - Lifecycle

    override func setUp() {
        homeKitAccessibleMock = HomeKitAccessMock()
        roomDataAccessibleMock = RoomDataAccessibleMock()
        refreshNotificationMock = RefreshNotificationMock()
        sut = RoomsViewModel(homeKitAccessible: homeKitAccessibleMock,
                             roomDataAccessible: roomDataAccessibleMock,
                             refreshNotification: refreshNotificationMock)
    }

    override func tearDown() {
        roomsSinkCancel = nil
        isShowingErrorCancel = nil
        errorMessageCancel = nil
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

    private var isShowingErrorCancel: AnyCancellable?
    private var errorMessageCancel: AnyCancellable?
    func testErrorIsShownWhenErrorRaisedWhileAccessingRooms() {
        let expectErrorShown = expectation(description: "Error Shown")
        let expectErrorMesssage = expectation(description: "Error Message")

        homeKitAccessibleMock.whenRoomsHasError()

        isShowingErrorCancel = sut.$isShowingError.sink { isShowing in
            if isShowing {
                expectErrorShown.fulfill()
            }
        }

        errorMessageCancel = sut.$errorMessage.sink { errorMessage in
            if errorMessage != nil {
                expectErrorMesssage.fulfill()
            }
        }

        roomsSinkCancel = sut.$rooms.sink { rooms in
            if rooms.count > 0 {
                XCTFail("rooms not expected")
            }
        }

        sut.onAppear()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectErrorShown, expectErrorMesssage], timeout: 1))
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
}
