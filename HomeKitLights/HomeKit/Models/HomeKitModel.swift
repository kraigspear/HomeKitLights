//
//  HomeKitModel.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import HomeKit

/// HomeKit model shared between all HomeKit model types
protocol HomeKitModel {
    /// The name of the model
    var name: String { get }
    /// The unique identifier for this model.
    var uniqueIdentifier: UUID { get }
}
