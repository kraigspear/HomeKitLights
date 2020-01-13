//
//  RoomAccessor.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import CoreData
import Foundation
import os.log

protocol RoomDataAccessible {
    func updateAccessTimeForRoom(id: UUID)
}

final class RoomAccessor: RoomDataAccessible {
    private let modelName = "HomeKitLights"
    private let log = Log.data

    private let entityRoom = "RoomEntity"
    private let fieldID = "id"
    private let fieldLastAccessed = "lastAccessed"

    private var rooms: [NSManagedObject] = []

    static let sharedAccessor = RoomAccessor()

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

    // MARK: - Access Time

    /// Update the last accessed time to now, for the Room with the given UUID
    /// - Parameter id: The UUID of the room to update access time for
    func updateAccessTimeForRoom(id: UUID) {
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
    }

    // MARK: -  Save

    private func saveContext() {
        guard managedContext.hasChanges else { return }

        do {
            try managedContext.save()
        } catch {
            os_log("Error: %s",
                   log: log,
                   type: .error,
                   error.localizedDescription)
        }
    }
}
