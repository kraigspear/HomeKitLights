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

    private var brightnessCancel: AnyCancellable?

    @Published var isBusy = false
    @Published var brightness: Double = 0.0
    @Published var areLightsOn = false
    @Published var imageOpacity: Float = 0.0
    @Published var imageName = "LightOff"

    init(room: Room,
         homeKitAccessible: HomeKitAccessible,
         roomDataAccessible: RoomDataAccessible,
         hapticFeedback: HapticFeedbackProtocol) {
        self.room = room
        self.homeKitAccessible = homeKitAccessible
        self.roomDataAccessible = roomDataAccessible
        self.hapticFeedback = hapticFeedback
        setInitialBrightness()
        sinkToBrightness()
    }

    private func setInitialBrightness() {
        brightness = Double(room.maxBrightness)
        areLightsOn = room.areAnyLightsOn
        updateLightOpacity()
    }

    private func updateLightOpacity() {
        imageName = areLightsOn ? "LightOn" : "LightOff"

        if areLightsOn {
            imageOpacity = Float(brightness) / 100.0
        } else {
            imageOpacity = 1.0
        }

        os_log("updateLightOpacity areLightsOn: %s, opactiy: %f",
               log: log,
               type: .debug,
               areLightsOn.description,
               Float(imageOpacity))
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

    private var sinkToBrightnessCancel: AnyCancellable?
    /// Subscribe to brightness changes
    private func sinkToBrightness() {
        sinkToBrightnessCancel = updatedateBrigthnessPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                completed in

                switch completed {
                case let .failure(error):
                    os_log("Error syncing brightness: %s",
                           log: self.log,
                           type: .error,
                           error.localizedDescription)
                case .finished:
                    os_log("Finished sinking brightness",
                           log: Log.homeKitAccess,
                           type: .debug)
                }

            }) { _ in
                self.updateLightOpacity()
            }
    }

    /// Publisher providing a publisher that updates the brightness
    private var updatedateBrigthnessPublisher: AnyPublisher<Void, Error> {
        $brightness.debounce(for: 1.0, scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .map { Int($0) }
            .filter { $0 != self.room.maxBrightness } // Avoid setting to the current value - on startup
            .removeDuplicates()
            .flatMap { brightness -> AnyPublisher<Void, Error> in

                os_log("Updating brightness to value: %d",
                       log: Log.homeKitAccess,
                       type: .debug,
                       brightness)

                self.hapticFeedback.impactOccurred()
                return self.homeKitAccessible.updateBrightness(brightness, forRoom: self.room).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}
