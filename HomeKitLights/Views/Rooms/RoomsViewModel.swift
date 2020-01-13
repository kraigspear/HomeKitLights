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

/// Filter that can be applked to rooms
enum RoomFilter: Int {
    /// No filter, all rooms should be shown.
    case all = 0
    /// Only rooms with lights that are off should be shown.
    case off = 1
    /// Only rooms with lights that are on should be shown.
    case on = 2
}

/// ViewModel showing HomeKit rooms containing lights
final class RoomsViewModel: ObservableObject {
    // MARK: - Members

    private let log = Log.lightsView

    /// Rooms that lights are in
    @Published var rooms: [Room] = []

    /// True to show an alert, showing an error message
    @Published var isShowingError = false

    /// Error message to show in an Alert
    @Published var errorMessage: String? = nil

    @Published var filterIndex = 0 {
        didSet {
            updateFilter()
        }
    }

    /// All rooms, Filters are applied to this array
    private var allRooms: [Room] = []

    /// Access to HomeKit
    let homeKitAccessible: HomeKitAccessible

    // MARK: - Init

    /// Initialize a new instance with access to HomeKit
    /// - Parameter homeKitAccessible: Access to HomeKit
    init(homeKitAccessible: HomeKitAccessible) {
        self.homeKitAccessible = homeKitAccessible
    }

    /// Init with defaults
    convenience init() {
        self.init(homeKitAccessible: HomeKitAccess())
    }

    // MARK: - Lifecycle

    /// Called when a view appears
    func onAppear() {
        os_log("onAppear",
               log: log,
               type: .info)
        reloadRooms()
    }

    // MARK: - Loading

    /// Allows cancelling of reloadRooms
    private var reloadRoomsCancel: AnyCancellable?

    /// Reload rooms from HomeKit
    private func reloadRooms() {
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
                self.updateFilter()
            }
    }

    private func updateFilter() {
        let filter = RoomFilter(rawValue: filterIndex)!

        switch filter {
        case .all:
            rooms = allRooms
        case .off:
            rooms = allRooms.filter { $0.accessories.any(itemsAre: { !$0.isOn }) }
        case .on:
            rooms = allRooms.filter { $0.accessories.any(itemsAre: { $0.isOn }) }
        }
    }
}
