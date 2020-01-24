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
    /// This method tells the generator that an impact has occurred
    func impactOccurred()
}

final class HapticFeedbackMock: HapticFeedbackProtocol {
    private(set) var impactOccurredCount = 0
    func impactOccurred() { impactOccurredCount += 1 }
}

/// Wrapper around UIImpactFeedbackGenerator for unit testing.
final class HapticFeedback: HapticFeedbackProtocol {
    private let feedGenerator = UIImpactFeedbackGenerator(style: .medium)

    /// Static instance, only once instance should be created
    static var sharedHapticFeedback = HapticFeedback()

    private init() {}

    /// This method tells the generator that an impact has occurred
    func impactOccurred() {
        feedGenerator.impactOccurred()
    }
}
