//
//  HomeKitAccessPreview.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/9/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation

class HomeKitAccessPreview: HomeKitAccessible {
    private var roomsValue: [Room]?
    private var roomsError: HomeKitAccessError?

    func whenHasRooms() {
        roomsValue = RoomMock.rooms()
    }

    func whenRoomsHasError() {
        roomsError = HomeKitAccessError.homeNotFound
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
