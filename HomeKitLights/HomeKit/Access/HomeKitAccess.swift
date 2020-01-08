//
//  HomeKitAccess.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import HomeKit

/// Errors that can occure when accessing HomeKit
enum HomeKitAccessError: Error {
    /// There isn't a home associated with this account / device
    /// Nothing can happen.
    /// A good course of action would be to inform the user how to setup HomeKit
    case homeNotFound
}

/// Access to HomeKit data
protocol HomeKitAccessible {
    /// HomeKit rooms associtated with this account / device
    /// - Remarks: Only rooms for the first home is returned. Multiple homes are not supported.
    var rooms: AnyPublisher<[RoomProtocol], HomeKitAccessError> { get }
}

/// Access to HomeKit
final class HomeKitAccess: HomeKitAccessible {
    /// Manager used to access home kit
    private let homeKitHomeManager = HMHomeManager()
    
    /// HomeKit rooms associtated with this account / device
    /// - Remarks: Only rooms for the first home is returned. Multiple homes are not supported.
    var rooms: AnyPublisher<[RoomProtocol], HomeKitAccessError> {
        Future<[RoomProtocol], HomeKitAccessError> { promise in
            
            guard let firstHome = self.homeKitHomeManager.homes.first else {
                promise(.failure(HomeKitAccessError.homeNotFound))
                return
            }
            
            let rooms = firstHome.rooms.map { Room(homeKitRoom: $0) }
            promise(.success(rooms))
        }.eraseToAnyPublisher()
    }
}

class HomeKitAccessMock: HomeKitAccessible {
    private var roomsValue: [RoomProtocol]?
    private var roomsError: HomeKitAccessError?
    
    func whenHasRooms() {
        roomsValue = RoomMock.rooms()
    }
    
    func whenRoomsHasError() {
        roomsError = HomeKitAccessError.homeNotFound
    }
    
    var rooms: AnyPublisher<[RoomProtocol], HomeKitAccessError> {
        if let roomsValue = roomsValue {
            return Just<[RoomProtocol]>(roomsValue)
                .setFailureType(to: HomeKitAccessError.self)
                .eraseToAnyPublisher()
        }
        
        if let roomsError = roomsError {
            return Fail<[RoomProtocol], HomeKitAccessError>(error: roomsError).eraseToAnyPublisher()
        }
        
        preconditionFailure("Expected result or error")
    }
}
