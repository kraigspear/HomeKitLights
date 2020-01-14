//
//  HapticFeedback.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/13/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import UIKit

/// Provides Haptic feedback
protocol HapticFeedbackProtocol {
    /// Impact has occured
    func impactOccurred()
}

final class HapticFeedbackMock: HapticFeedbackProtocol {
    func impactOccurred() {}
}

/// Wrapper around UIImpactFeedbackGenerator for unit testing.
final class HapticFeedback: HapticFeedbackProtocol {
    private let feedGenerator = UIImpactFeedbackGenerator(style: .medium)

    static var sharedHapticFeedback = HapticFeedback()

    private init() {}

    func impactOccurred() {
        feedGenerator.impactOccurred()
    }
}
