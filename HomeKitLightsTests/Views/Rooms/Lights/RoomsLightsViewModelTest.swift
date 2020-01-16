//
//  RoomsLightsViewModelTest.swift
//  HomeKitLightsTests
//
//  Created by Kraig Spear on 1/16/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
@testable import HomeKitLights
import XCTest

final class RoomsLightsViewModelTest: XCTestCase {
    // MARK: - Dependencies

    private var homeKitAccessibleMock: HomeKitAccessMock!
    private var roomDataAccessibleMock: RoomDataAccessibleMock!
    private var hapticFeedbackMock: HapticFeedbackMock!

    // MARK: - Subject under test

    private var sut: RoomLightsViewModel!

    // MARK: - Lifecycle

    override func setUp() {
        homeKitAccessibleMock = HomeKitAccessMock()
        roomDataAccessibleMock = RoomDataAccessibleMock()
        hapticFeedbackMock = HapticFeedbackMock()

        let room = RoomMock.diningRoom()

        sut = RoomLightsViewModel(room: room,
                                  homeKitAccessible: homeKitAccessibleMock,
                                  roomDataAccessible: roomDataAccessibleMock,
                                  hapticFeedback: hapticFeedbackMock)
    }

    override func tearDown() {
        isBusyCancel = nil
        imageOpacityCancel = nil
    }

    func testHapticFeedbackWhenToggled() {
        XCTAssertEqual(0, hapticFeedbackMock.impactOccurredCount)
        sut.toggle()
        XCTAssertEqual(1, hapticFeedbackMock.impactOccurredCount)
    }

    private var isBusyCancel: AnyCancellable?
    func testBusyWhenToggledThenSetbackToNotBusyWhenToggleComplete() {
        let expectIsBusy = expectation(description: "isBusy")
        let expectIsNotBusy = expectation(description: "isNotBusy")

        expectIsBusy.expectedFulfillmentCount = 1
        expectIsNotBusy.expectedFulfillmentCount = 1

        isBusyCancel = sut.$isBusy.sink { isBusy in

            if isBusy {
                expectIsBusy.fulfill()
            } else {
                expectIsNotBusy.fulfill()
            }
        }

        sut.toggle()

        homeKitAccessibleMock.sendToggleSuccess()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectIsBusy, expectIsNotBusy], timeout: 1))
    }

    func testLastAcccessTimeIsStoredWhenToggledSuccessfully() {
        let expectIsBusy = expectation(description: "isBusy")
        let expectIsNotBusy = expectation(description: "isNotBusy")

        expectIsBusy.expectedFulfillmentCount = 1
        expectIsNotBusy.expectedFulfillmentCount = 2

        isBusyCancel = sut.$isBusy.sink { isBusy in

            if isBusy {
                expectIsBusy.fulfill()
            } else {
                expectIsNotBusy.fulfill()
            }
        }

        let expectUpdateAccessTimeCalled = expectation(description: "expectUpdateAccessTimeCalled")
        roomDataAccessibleMock.updateAccessTimeForRoomCalled = {
            expectUpdateAccessTimeCalled.fulfill()
        }

        sut.toggle()

        homeKitAccessibleMock.sendToggleSuccess()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectIsBusy, expectIsNotBusy, expectUpdateAccessTimeCalled], timeout: 1))
    }

    func testLastAcccessTimeIsNotStoredWhenToggledHasError() {
        let expectIsBusy = expectation(description: "isBusy")
        let expectIsNotBusy = expectation(description: "isNotBusy")

        expectIsBusy.expectedFulfillmentCount = 1
        expectIsNotBusy.expectedFulfillmentCount = 2

        isBusyCancel = sut.$isBusy.sink { isBusy in

            if isBusy {
                expectIsBusy.fulfill()
            } else {
                expectIsNotBusy.fulfill()
            }
        }

        roomDataAccessibleMock.updateAccessTimeForRoomCalled = {
            XCTFail("Update not expected")
        }

        sut.toggle()

        homeKitAccessibleMock.sendToggleError()

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectIsBusy, expectIsNotBusy], timeout: 1))
    }

    // MARK: - Brightness

    private var imageOpacityCancel: AnyCancellable?

    func testImageOpacityBrightness() {
        sut.brightness = 25.5

        let expectOpacity = expectation(description: "expectOpacity")
        expectOpacity.expectedFulfillmentCount = 2 // Initial + change

        var setOpacity: Float = 0.0
        imageOpacityCancel = sut.$imageOpacity.sink { opacity in
            setOpacity = opacity
            expectOpacity.fulfill()
        }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expectOpacity], timeout: 2))

        XCTAssertEqual(0.255, setOpacity)
    }
}
