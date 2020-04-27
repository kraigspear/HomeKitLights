//
//  RefreshNotification.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Combine
import UIKit

/// A refresh should occur
/// SeeAlso: `RoomsViewModel`
protocol RefreshNotificationProtocol {
    /**
     Publisher that notifies that a refresh should occur.
     ```swift
     private func sinkToForegroundNotification() {
         refreshNotificationCancel = refreshNotification.refreshPublisher.sink { _ in

             os_log("refreshNotification refresh",
                    log: self.log,
                    type: .debug)

             self.homeKitAccessible.reload()
         }
     }
     ```
     */
    var refreshPublisher: AnyPublisher<Notification, Never> { get }
}

/// Mock for Unit Testing & Previews
final class RefreshNotificationMock: RefreshNotificationProtocol {
    func whenNotificationPosted() {
        let notification = Notification(name: UIApplication.willEnterForegroundNotification)
        refreshPassThrough.send(notification)
    }

    private var refreshPassThrough = PassthroughSubject<Notification, Never>()

    var refreshPublisher: AnyPublisher<Notification, Never> {
        refreshPassThrough.eraseToAnyPublisher()
    }
}

/// Notification indicating that data should reload
final class RefreshNotification: RefreshNotificationProtocol {
    /**
     Publisher that notifies that a refresh should occur.
     ```swift
     private func sinkToForegroundNotification() {
         refreshNotificationCancel = refreshNotification.refreshPublisher.sink { _ in

             os_log("refreshNotification refresh",
                    log: self.log,
                    type: .debug)

             self.homeKitAccessible.reload()
         }
     }
     ```
     */
    var refreshPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).eraseToAnyPublisher()
    }
}
