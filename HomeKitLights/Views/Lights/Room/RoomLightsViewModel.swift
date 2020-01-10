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

    private var cancelToggle: AnyCancellable?

    @Published var isBusy = false

    init(room: Room,
         homeKitAccessible: HomeKitAccessible) {
        self.room = room
        self.homeKitAccessible = homeKitAccessible
    }

    func toggle() {
        os_log("Toggle: %s",
               log: log,
               type: .debug,
               room.name)

        isBusy = true

        cancelToggle = homeKitAccessible.toggle(room)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in

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
                }

            }) { _ in
            }
    }
}
