//
//  RoomViewStyleModifier.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/14/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import SwiftUI

/// Common style for the room view
struct RoomViewStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(Color("RoomBackground"))
            .cornerRadius(20)
            .padding(.leading, 14)
            .padding(.trailing, 14)
            .padding(.bottom, 12)
    }
}

extension View {
    /// Apply the room style
    func roomStyle() -> some View {
        modifier(RoomViewStyleModifier())
    }
}
