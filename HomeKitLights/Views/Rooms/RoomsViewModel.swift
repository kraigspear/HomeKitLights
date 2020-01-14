//
//  LightsViewModel.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import os.log

/// Filter that can be applied to rooms
enum RoomFilter: Int {
    /// No filter, all rooms should be shown.
    case all = 0
    /// Only rooms with lights that are off should be shown.
    case off = 1
    /// Only rooms with lights that are on should be shown.
    case on = 2
}

/// Sort that can be applied to rooms
enum RoomSort: Int {
    /// Sorted by Room Name
    case alphabetical = 0
    /// Sorted by last updated
    case lastUpdated = 1
}

/// ViewModel showing HomeKit rooms containing lights
final class RoomsViewModel: ObservableObject {
    // MARK: - Members

    private static let FilterButtonImage = "SortFilter"
    private static let FilterButtonImageFilled = "SortFilterFilled"

    private let log = Log.lightsView

    /// Rooms that lights are in
    @Published var rooms: [Room] = []

    /// True to show an alert, showing an error message
    @Published var isShowingError = false

    /// Error message to show in an Alert
    @Published var errorMessage: String? = nil

    @Published var filterIndex = 0 {
        didSet {
            applySortFilter()
        }
    }

    @Published var sortIndex = 0 {
        didSet {
            applySortFilter()
        }
    }

    @Published var filterButtonImage = RoomsViewModel.FilterButtonImage
    @Published var isShowingSortFilter = false {
        didSet {
            filterButtonImage = isShowingSortFilter ? RoomsViewModel.FilterButtonImageFilled : RoomsViewModel.FilterButtonImage
        }
    }

    func toggleShowingFilter() {
        isShowingSortFilter.toggle()
    }

    /// All rooms, Filters are applied to this array
    private var allRooms: [Room] = []

    /// Access to HomeKit
    let homeKitAccessible: HomeKitAccessible

    private let roomDataAccessible: RoomDataAccessible

    private var roomsUpdatedCancel: AnyCancellable?

    // MARK: - Init

    /// Initialize a new instance with access to HomeKit
    /// - Parameter homeKitAccessible: Access to HomeKit
    init(homeKitAccessible: HomeKitAccessible,
         roomDataAccessible: RoomDataAccessible,
         refreshNotification: RefreshNotificationProtocol) {
        self.homeKitAccessible = homeKitAccessible
        self.roomDataAccessible = roomDataAccessible
        self.refreshNotification = refreshNotification

        sinkToRooms()

        roomsUpdatedCancel = roomDataAccessible.roomsUpdated.sink {
            homeKitAccessible.reload()
        }

        sinkToForegroundNotification()
    }

    /// Init with defaults
    convenience init() {
        self.init(homeKitAccessible: HomeKitAccess(),
                  roomDataAccessible: RoomAccessor.sharedAccessor,
                  refreshNotification: RefreshNotification())
    }

    // MARK: - Lifecycle

    /// Called when a view appears
    func onAppear() {
        os_log("onAppear",
               log: log,
               type: .info)
        homeKitAccessible.reload()
    }

    // MARK: - Loading

    /// Allows cancelling of reloadRooms
    private var reloadRoomsCancel: AnyCancellable?

    /// Sink to any room changes
    private func sinkToRooms() {
        os_log("reloadRooms",
               log: log,
               type: .info)

        reloadRoomsCancel = homeKitAccessible.rooms.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

                switch completed {
                case let .failure(error):
                    os_log("Error: %s",
                           log: self.log,
                           type: .error,
                           error.localizedDescription)

                    switch error {
                    case HomeKitAccessError.homeNotFound:
                        self.errorMessage = "Homekit isn't setup"
                    }

                    self.isShowingError = true

                case .finished:
                    os_log("Done loading rooms",
                           log: self.log,
                           type: .info)
                }

            }) { loadedRooms in

                os_log("Loaded %d rooms",
                       log: self.log,
                       type: .debug,
                       loadedRooms.count)

                self.allRooms = loadedRooms
                self.applySortFilter()
            }
    }

    private func applySortFilter() {
        os_log("applySortFilter",
               log: Log.homeKitAccess,
               type: .debug)

        let filter = RoomFilter(rawValue: filterIndex)!
        let sort = RoomSort(rawValue: sortIndex)

        var sortedFilteredRooms: [Room] = []

        switch filter {
        case .all:
            sortedFilteredRooms = allRooms
        case .off:
            sortedFilteredRooms = allRooms.filter { $0.lights.any(itemsAre: { !$0.isOn }) }
        case .on:
            sortedFilteredRooms = allRooms.filter { $0.lights.any(itemsAre: { $0.isOn }) }
        }

        // Sort by name first to start with name ascending.
        sortedFilteredRooms.sort { $0.name < $1.name }

        if sort == RoomSort.alphabetical {
            rooms = sortedFilteredRooms
            return
        }

        let lastAccessedRooms = roomDataAccessible.fetchLastAccessedRooms()

        struct RoomLastAccessed {
            let room: Room
            let dateLastAccessed: Date
        }

        var roomsLastAccessed = sortedFilteredRooms.map { room -> RoomLastAccessed in
            let lastAccessed = lastAccessedRooms[room.id] ?? Date(timeIntervalSince1970: 0)
            return RoomLastAccessed(room: room, dateLastAccessed: lastAccessed)
        }

        roomsLastAccessed.sort { $0.dateLastAccessed > $1.dateLastAccessed }

        rooms = roomsLastAccessed.map { $0.room }
    }

    // MARK: - Foreground Notification

    private var refreshNotificationCancel: AnyCancellable?
    private let refreshNotification: RefreshNotificationProtocol

    private func sinkToForegroundNotification() {
        refreshNotificationCancel = refreshNotification.refreshPublisher.sink { _ in

            os_log("refreshNotification refesh",
                   log: self.log,
                   type: .debug)

            self.homeKitAccessible.reload()
        }
    }
}
