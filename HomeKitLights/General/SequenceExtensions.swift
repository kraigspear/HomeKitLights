//
//  SequenceExtensions.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation

extension Sequence {
    func any(itemsAre check: (Self.Element) -> Bool) -> Bool {
        first(where: check) != nil
    }
}
