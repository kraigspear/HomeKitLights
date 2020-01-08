//
//  Log.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import os.log

/// Logs
struct Log {
    /// Log for view containing lights
    static let lightsView = OSLog(subsystem: "com.dornerworks.HomeKitLights", category: "💡lightsView")
}
