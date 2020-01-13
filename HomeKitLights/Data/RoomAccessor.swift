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

protocol RoomDataAccessible {
    /// Update the last accessed times for a room
    /// - Parameter id: ID of the room to update
    func updateAccessTimeForRoom(id: UUID)

    /// Dictionary of Dates keyd by the ID of the room, last accessed
    func fetchLastAccessedRooms() -> [UUID: Date]

    /// Publisher when rooms have been updated
    var roomsUpdated: AnyPublisher<Void, Never> { get }
}

final class RoomAccessor: RoomDataAccessible {
    private let modelName = "HomeKitLights"
    private let log = Log.data

    private let entityRoom = "RoomEntity"
    private let fieldID = "id"
    private let fieldLastAccessed = "lastAccessed"

    private var rooms: [NSManagedObject] = []

    static let sharedAccessor = RoomAccessor()

    private let roomsUpdatedSubject = PassthroughSubject<Void, Never>()

    public var roomsUpdated: AnyPublisher<Void, Never> {
        roomsUpdatedSubject.eraseToAnyPublisher()
    }

    private init() {}

    // MARK: - Room Request

    private var roomRequest: NSFetchRequest<NSManagedObject> {
        NSFetchRequest<NSManagedObject>(entityName: entityRoom)
    }

    private func requestForRoom(id: UUID) -> NSFetchRequest<NSManagedObject> {
        let request = roomRequest
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return request
    }

    private lazy var roomContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
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
