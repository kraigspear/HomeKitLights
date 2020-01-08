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
    var rooms: AnyPublisher<[Room], HomeKitAccessError> { get }
}

/// Access to HomeKit
final class HomeKitAccess: NSObject, HomeKitAccessible {
    
    private let log = Log.homeKitAccess
    
    /// Manager used to access home kit
    private let homeKitHomeManager = HMHomeManager()
    
    override init() {
        super.init()
        homeKitHomeManager.delegate = self
    }
    
    private let roomsCurrentValueSubject = CurrentValueSubject<[Room], HomeKitAccessError>([])
    
    /// HomeKit rooms associtated with this account / device
    /// - Remarks: Only rooms for the first home is returned. Multiple homes are not supported.
    var rooms: AnyPublisher<[Room], HomeKitAccessError> {
        roomsCurrentValueSubject.eraseToAnyPublisher()
    }
    
    private func reload() {
        
        guard let firstHome = self.homeKitHomeManager.homes.first else {
            return
        }
        
        roomsCurrentValueSubject.value = firstHome.rooms.map { Room(name: $0.name, id: $0.uniqueIdentifier) }
    }
}

extension HomeKitAccess: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ homeManager: HMHomeManager) {
        reload()
    }
}

class HomeKitAccessMock: HomeKitAccessible {
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
