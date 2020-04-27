//
//  RoomAccessor.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import CoreData
import Foundation
import os.log

/// Access to the local database
protocol RoomDatabaseAccessible {
    /// Update the last accessed times for a room.
    /// Should be called when a room has been selected
    /// - Parameter id: ID of the room to update
    func updateAccessTimeForRoom(id: UUID)

    /// Dictionary of Dates keyed by the ID of the room, last accessed
    func fetchLastAccessedRooms() -> [UUID: Date]

    /// Publisher when rooms have been updated
    var roomsUpdated: AnyPublisher<Void, Never> { get }
}

/// Access to the local data store for rooms
final class RoomDatabaseAccessor: RoomDatabaseAccessible {
    private let coreDataModelName = "HomeKitLights"
    private let log = Log.data

    private let entityRoom = "RoomEntity"
    private let fieldID = "id"
    private let fieldLastAccessed = "lastAccessed"

    /// Rooms loaded from CoreData
    private var rooms: [NSManagedObject] = []

    /// Singleton shared instance
    static let sharedAccessor = RoomDatabaseAccessor()

    /// Notify client of changes to the rooms entity
    private let roomsUpdatedSubject = PassthroughSubject<Void, Never>()

    ///  Notify client of changes to the rooms entity
    public var roomsUpdated: AnyPublisher<Void, Never> {
        roomsUpdatedSubject.eraseToAnyPublisher()
    }

    private init() {}

    // MARK: - Room Request

    /// Request returning all rooms.
    private var roomRequest: NSFetchRequest<NSManagedObject> {
        NSFetchRequest<NSManagedObject>(entityName: entityRoom)
    }

    /// Request returning one room
    /// - Parameter id: ID of the room to fetch
    private func requestForRoom(id: UUID) -> NSFetchRequest<NSManagedObject> {
        let request = roomRequest
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return request
    }

    /// PersistentContainer for HomeKitLights
    private lazy var roomContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: coreDataModelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                os_log("Error loading CoreData: %s",
                       log: self.log,
                       type: .error,
                       error.localizedDescription)
            } else {
                os_log("CoreData loaded",
                       log: self.log,
                       type: .info)
            }
        }
        return container
    }()

    private lazy var managedContext: NSManagedObjectContext = {
        self.roomContainer.viewContext
    }()

    // MARK: - Loading

    ///
    func reload() {
        do {
            rooms = try managedContext.fetch(roomRequest)
        } catch {
            os_log("Error: %s",
                   log: log,
                   type: .error,
                   error.localizedDescription)
        }
    }

    // MARK: - Last Accessed

    /// Fetch ID's and Dates of rooms that can be used to sort by last accessed
    func fetchLastAccessedRooms() -> [UUID: Date] {
        var lastAccessed: [UUID: Date] = [:]

        reload()

        for room in rooms {
            guard let date = room.value(forKey: fieldLastAccessed) as? Date,
                let id = room.value(forKey: fieldID) as? UUID else {
                os_log("Didn't find the date and ID for a saved room",
                       log: log,
                       type: .error)

                continue
            }

            lastAccessed[id] = date
        }

        return lastAccessed
    }

    // MARK: - Access Time

    /// Update the last accessed time to now, for the Room with the given UUID
    /// The last time is stored so that the UI can sort by last accessed.d
    /// - Parameter id: The UUID of the room to update access time for
    func updateAccessTimeForRoom(id: UUID) {
        os_log("updateAccessTimeForRoom",
               log: Log.homeKitAccess,
               type: .debug)

        var roomManagedObjects: [NSManagedObject] = []

        do {
            roomManagedObjects = try managedContext.fetch(requestForRoom(id: id))
        } catch {
            os_log("Error: %s",
                   log: log,
                   type: .error,
                   error.localizedDescription)
            return
        }

        var roomManagedObject: NSManagedObject?

        if roomManagedObjects.isEmpty {
            os_log("New database entry",
                   log: Log.homeKitAccess,
                   type: .debug)
            let entity = NSEntityDescription.entity(forEntityName: entityRoom, in: managedContext)!
            roomManagedObject = NSManagedObject(entity: entity, insertInto: managedContext)
            roomManagedObject!.setValue(id, forKey: fieldID)
        } else {
            os_log("Using existing database entry",
                   log: Log.homeKitAccess,
                   type: .debug)
            roomManagedObject = roomManagedObjects.first
        }

        roomManagedObject!.setValue(Date(), forKey: fieldLastAccessed)
        saveContext()
        reload()
        roomsUpdatedSubject.send()
    }

    // MARK: -  Save

    /// Save changes back to the managedContext
    private func saveContext() {
        guard managedContext.hasChanges else { return }

        do {
            try managedContext.save()
            os_log("Core data updated",
                   log: Log.homeKitAccess,
                   type: .debug)

        } catch {
            os_log("Error: %s",
                   log: log,
                   type: .error,
                   error.localizedDescription)
        }
    }
}

final class RoomDatabaseAccessorMock: RoomDatabaseAccessible {
    func sendRoomDataUpdated() {
        roomsUpdatedSubject.send(())
    }

    private(set) var updateAccessTimeForRoomUUID: UUID?

    var updateAccessTimeForRoomCalled: (() -> Void)?

    func updateAccessTimeForRoom(id: UUID) {
        updateAccessTimeForRoomUUID = id
        updateAccessTimeForRoomCalled?()
    }

    func fetchLastAccessedRooms() -> [UUID: Date] {
        lastAccessedRoomsValue
    }

    var lastAccessedRoomsValue: [UUID: Date] = [:]

    private var roomsUpdatedSubject = PassthroughSubject<Void, Never>()
    var roomsUpdated: AnyPublisher<Void, Never> {
        roomsUpdatedSubject.eraseToAnyPublisher()
    }
}
