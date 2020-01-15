//
//  RoomEntity+CoreDataProperties.swift
//
//
//  Created by Kraig Spear on 1/15/20.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension RoomEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomEntity> {
        return NSFetchRequest<RoomEntity>(entityName: "RoomEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastAccessed: Date?
}
