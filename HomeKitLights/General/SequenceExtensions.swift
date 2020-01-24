//
//  SequenceExtensions.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation

extension Sequence {
    /// Does a check if any items match check
    /// - Parameter check: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    func any(itemsAre check: (Self.Element) -> Bool) -> Bool {
        first(where: check) != nil
    }
}
