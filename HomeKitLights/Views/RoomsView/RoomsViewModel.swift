//
//  LightsViewModel.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import os.log
import UIKit

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

    private let log = Log.lightsView

    /// Rooms that lights are in
    @Published var rooms: Rooms = []

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

    static let FilterButtonImage = "SortFilter"
    static let FilterButtonImageFilled = "SortFilterFilled"

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
    private var allRooms: Rooms = [] {
        didSet {
            isEmptyStateVisible = allRooms.isEmpty
        }
    }

    /// Access to HomeKit
    let homeKitAccessible: HomeKitAccessible
    private let roomDataAccessible: RoomDataAccessible

    /// Open Settings, Home App
    private let urlOpener: URLOpenable

    /// Sorts filters rooms
    private let roomFilterSortable: RoomFilterSortable

    private var roomsUpdatedCancel: AnyCancellable?

    // MARK: - Empty State

    /// There are no rooms, empty state should be shown.
    @Published var isEmptyStateVisible = true

    /// Missing HomeKit permissions, permission request state should be shown.
    @Published var isMissingPermissionStateVisisble = true

    // MARK: - Init

    /// Initialize a new instance with access to HomeKit
    /// - Parameter homeKitAccessible: Access to HomeKit
    /// - Parameter roomDataAccessible: Access to room data, when was a light last accessed
    /// - Parameter roomFilterSortable: Sorts filters rooms
    /// - Parameter refreshNotification: Notification that data should be refreshed
    /// - urlOpener: Allows opening URL's for settings and the Home App
    init(homeKitAccessible: HomeKitAccessible,
         roomDataAccessible: RoomDataAccessible,
         roomFilterSortable: RoomFilterSortable,
         refreshNotification: RefreshNotificationProtocol,
         urlOpener: URLOpenable) {
        self.homeKitAccessible = homeKitAccessible
        self.roomDataAccessible = roomDataAccessible
        self.roomFilterSortable = roomFilterSortable
        self.refreshNotification = refreshNotification
        self.urlOpener = urlOpener

        sinkToRooms()
        sinkToDataChanges()
        sinkToForegroundNotification()
    }

    /// Sink to any changes from the database.
    /// Occurs when the last selected item is set
    private func sinkToDataChanges() {
        roomsUpdatedCancel = roomDataAccessible.roomsUpdated.sink {
            self.isMissingPermissionStateVisisble = !self.homeKitAccessible.authorizationStatus().contains(.authorized)
            self.homeKitAccessible.reload()
        }
    }

    /// Init with defaults
    convenience init() {
        self.init(homeKitAccessible: HomeKitAccess(),
                  roomDataAccessible: RoomAccessor.sharedAccessor,
                  roomFilterSortable: RoomFilterSort(),
                  refreshNotification: RefreshNotification(),
                  urlOpener: URLOpener())
    }

    // MARK: - Lifecycle

    /// Called when a view appears
    func onAppear() {
        os_log("onAppear",
               log: log,
               type: .info)
        isMissingPermissionStateVisisble = !homeKitAccessible.authorizationStatus().contains(.authorized)
        homeKitAccessible.reload()
    }

    // MARK: - Loading

    /// Allows cancelling of reloadRooms
    private var reloadRoomsCancel: AnyCancellable?

    /// Sink to any room changes
    private func sinkToRooms() {
        os_log("sinkToRooms",
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
        let sort = RoomSort(rawValue: sortIndex)!

        rooms = roomFilterSortable.apply(filter: filter,
                                         sort: sort,
                                         on: allRooms)
    }

    // MARK: - Foreground Notification

    private var refreshNotificationCancel: AnyCancellable?
    private let refreshNotification: RefreshNotificationProtocol

    private func sinkToForegroundNotification() {
        refreshNotificationCancel = refreshNotification.refreshPublisher.sink { _ in

            os_log("refreshNotification refesh",
                   log: self.log,
                   type: .debug)
            self.isMissingPermissionStateVisisble = !self.homeKitAccessible.authorizationStatus().contains(.authorized)
            self.homeKitAccessible.reload()
        }
    }

    // MARK: - Empty State

    ///  Shows the Home App so that the user can configure HomeKit
    func showHomeApp() {
        let url = URL(string: "com.apple.home://")!
        urlOpener.open(url)
    }

    /// Allows setting permissions for HomeKitLights. If the empty state is shown it might be
    /// because permissions have been removed.
    func showPermissions() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        urlOpener.open(url)
    }
}
