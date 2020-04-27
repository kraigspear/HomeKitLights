//
// Created by Kraig Spear on 4/27/20.
// Copyright (c) 2020 Kraig Spear. All rights reserved.
//

import Combine
import Foundation
import HomeKit
import os.log

protocol HomeKitAccessoryDelegateProtocol {
    func append(_ hmAccessory: HMAccessory)
    var accessoryUpdated: AnyPublisher<UUID, Never> { get }
}

final class HomeKitAccessoryDelegates: NSObject, HomeKitAccessoryDelegateProtocol, HMAccessoryDelegate {
    private let log = Log.homeKitAccess

    private var accessoryUpdatedSubject = PassthroughSubject<UUID, Never>()

    var accessoryUpdated: AnyPublisher<UUID, Never> {
        accessoryUpdatedSubject.eraseToAnyPublisher()
    }

    private var accessories: [HMAccessory] = []

    func append(_ hmAccessory: HMAccessory) {
        os_log("append: %s",
               log: log,
               type: .debug,
               hmAccessory.uniqueIdentifier.description)

        accessories.append(hmAccessory)
        hmAccessory.delegate = self

        //		if let brightnessCharacteristic = hmAccessory.brightnessCharacteristic {
//
//        }

        guard let lightBulbCharacteristic = hmAccessory.lightBulbCharacteristic else {
            assertionFailure("Didn't find lightBulbCharacteristic")
            return
        }

        if lightBulbCharacteristic.isNotificationEnabled { return }

        lightBulbCharacteristic.enableNotification(true) { error in
            if let error = error {
                os_log("Error enabling notification: %s",
                       log: self.log,
                       type: .error,
                       error.localizedDescription)
            } else {
                os_log("Success enabling notification",
                       log: self.log,
                       type: .debug)
            }
        }
    }

    /// Remove all of the existing delegate, accessories
    func removeAll() {
        os_log("removeAll",
               log: log,
               type: .debug)

        accessories.forEach { accessory in
            accessory.delegate = nil
        }

        accessories.removeAll()
    }

    func accessory(_ accessory: HMAccessory,
                   service _: HMService,
                   didUpdateValueFor _: HMCharacteristic) {
        accessoryUpdatedSubject.send(accessory.uniqueIdentifier)
    }
}
