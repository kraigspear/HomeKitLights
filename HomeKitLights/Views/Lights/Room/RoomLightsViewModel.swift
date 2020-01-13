//
//  RoomLightsViewModel.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import os.log

final class RoomLightsViewModel: ObservableObject {
    private let log = Log.lightsView
    private let room: Room
    private let homeKitAccessible: HomeKitAccessible
    private let roomDataAccessible: RoomDataAccessible
    private let hapticFeedback: HapticFeedbackProtocol

    private var cancelToggle: AnyCancellable?

    @Published var isBusy = false

    init(room: Room,
         homeKitAccessible: HomeKitAccessible,
         roomDataAccessible: RoomDataAccessible,
         hapticFeedback: HapticFeedbackProtocol) {
        self.room = room
        self.homeKitAccessible = homeKitAccessible
        self.roomDataAccessible = roomDataAccessible
        self.hapticFeedback = hapticFeedback
    }

    func toggle() {
        os_log("Toggle: %s",
               log: log,
               type: .debug,
               room.name)

        hapticFeedback.impactOccurred()

        isBusy = true

        cancelToggle = homeKitAccessible.toggle(room)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completed in

                guard let self = self else { return }

                defer {
                    self.isBusy = false
                }

                switch completed {
                case let .failure(error):
                    os_log("Error: %s",
                           log: self.log,
                           type: .error,
                           error.localizedDescription)
                case .finished:
                    os_log("Success toggle lights",
                           log: self.log,
                           type: .info)
                    self.roomDataAccessible.updateAccessTimeForRoom(id: self.room.id)
                }

            }) { _ in
            }
    }
}
