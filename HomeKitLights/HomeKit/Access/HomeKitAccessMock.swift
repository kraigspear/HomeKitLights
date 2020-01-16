//
//  HomeKitAccessMock.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/9/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation

final class HomeKitAccessMock: HomeKitAccessible {
    // MARK: - Rooms

    private var roomsValue: [Room]?
    private var roomsError: HomeKitAccessError?

    var rooms: AnyPublisher<[Room], HomeKitAccessError> {
        if let roomsValue = roomsValue {
            return Just<[Room]>(roomsValue)
                .setFailureType(to: HomeKitAccessError.self)
                .eraseToAnyPublisher()
        }

        if let roomsError = roomsError {
            return Fail<[Room], HomeKitAccessError>(error: roomsError).eraseToAnyPublisher()
        }

        preconditionFailure("Expected result or error")
    }

    func whenHasRooms() {
        roomsValue = RoomMock.rooms()
        roomsError = nil
    }

    func whenHasOneRoomOnAndOneRoomOff() {
        roomsValue = [RoomMock.roomWithLightOn(), RoomMock.roomWithLightOff()]
        roomsError = nil
    }

    func whenThereAreNoRooms() {
        roomsValue = []
        roomsError = nil
    }

    func whenRoomsHasError() {
        roomsValue = nil
        roomsError = HomeKitAccessError.homeNotFound
    }

    // MARK: - Toggle

    func whenToggleSuccess() {
        toggleSuccess = true
    }

    private var toggleSuccess = true

    private var toggleSubject = PassthroughSubject<Void, Error>()

    func sendToggleSuccess() {
        toggleSubject.send(())
        toggleSubject.send(completion: .finished)
    }

    func sendToggleError() {
        toggleSubject.send(completion: .failure(HomeKitAccessError.homeNotFound))
    }

    func toggle(_: Room) -> AnyPublisher<Void, Error> {
        toggleSubject.eraseToAnyPublisher()
    }

    // MARK: - Reload

    private(set) var reloadCalled = 0
    func reload() {
        reloadCalled += 1
    }

    // MARK: - Brightness

    func updateBrightness(_: Int, forRoom _: Room) -> AnyPublisher<Void, Error> {
        return Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
