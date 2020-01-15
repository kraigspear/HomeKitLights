//
//  HomeKitAccessMock.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/9/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation

class HomeKitAccessMock: HomeKitAccessible {
    func updateBrightness(_: Int, forRoom _: Room) -> AnyPublisher<Void, Error> {
        return Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private var roomsValue: [Room]?
    private var roomsError: HomeKitAccessError?

    private var toggleSuccess = true

    func whenHasRooms() {
        roomsValue = RoomMock.rooms()
    }

    func whenRoomsHasError() {
        roomsError = HomeKitAccessError.homeNotFound
    }

    func whenToggleSuccess() {
        toggleSuccess = true
    }

    func toggle(_: Room) -> AnyPublisher<Void, Error> {
        Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private(set) var reloadCalled = 0
    func reload() {
        reloadCalled += 1
    }

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
}
