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

/// ViewModel showing HomeKit lights
final class LightsViewModel: ObservableObject {
    // MARK: - Members

    private let log = Log.lightsView

    /// Rooms that lights are in
    @Published var rooms: [Room] = []
    @Published var isShowingError = false
    @Published var errorMessage: String? = nil

    /// Access to HomeKit
    private let homeKitAccessible: HomeKitAccessible

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

        reloadRoomsCancel = homeKitAccessible.rooms.sink(receiveCompletion: { completed in

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

            self.rooms = loadedRooms
        }
    }
}
