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

/// ViewModel backing the `RoomLightsView`
final class RoomLightsViewModel: ObservableObject {
    private let log = Log.lightsView

    // MARK: - Model

    /// Room for this ViewModel
    private let room: Room

    // MARK: - Dependencies

    /// Access to HomeKit to change room state
    private let homeKitAccessible: HomeKitAccessible

    /// Access to local room data. Last modified time.
    private let roomDataAccessible: RoomDataAccessible

    /// Access to the device haptic
    private let hapticFeedback: HapticFeedbackProtocol

    // MARK: - Published (View State)

    /// True if the view should indicate that it is busy. An indicator should be shown
    @Published var isBusy = false
    /// True if the view should show state indicating that the lights are on / off
    @Published var areLightsOn = false
    /// The opacity of the light images to indicate brightness
    @Published var imageOpacity: Float = 0.0
    /// The name of the image that represents a light.
    @Published var imageName = "LightOff"
    /// The brightness of the lights 0 - 1
    @Published var brightness: Double = 0.0

    // MARK: - Init

    /// Return a newly initialized RoomLightsViewModel
    /// - Parameters:
    ///   - room: Room that is being shown
    ///   - homeKitAccessible: Access to HomeKit to change room state
    ///   - roomDataAccessible: Access to local room data. Last modified time.
    ///   - hapticFeedback: Access to the device haptic's
    ///   - returns: Newly initialized RoomLightsViewModel
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

    /// Update the opacity being applied to the images when brightness and/or on value changes
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

    // MARK: - Toggle

    private var cancelToggle: AnyCancellable?

    /// Toggle power state
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

    // MARK: - Brightness

    private var brightnessCancel: AnyCancellable?

    private func setInitialBrightness() {
        brightness = Double(room.maxBrightness)
        areLightsOn = room.areAnyLightsOn
        updateLightOpacity()
    }

    private var sinkToBrightnessCancel: AnyCancellable?
    /// Subscribe to brightness changes
    private func sinkToBrightness() {
        sinkToBrightnessCancel = updateBrightnessPublisher
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
    private var updateBrightnessPublisher: AnyPublisher<Void, Error> {
        $brightness.debounce(for: 1.0, scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .map { Int($0) }
            .filter { $0 != self.room.maxBrightness } // Avoid setting to the current value - on startup
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
