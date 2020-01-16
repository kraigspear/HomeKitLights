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
protocol RefreshNotificationProtocol {
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

final class RefreshNotification: RefreshNotificationProtocol {
    var refreshPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).eraseToAnyPublisher()
    }
}
