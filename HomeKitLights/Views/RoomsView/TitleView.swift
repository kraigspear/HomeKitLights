//
//  TitleView.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import SwiftUI

/// View to use as a Tile
struct TitleView: View {
    private let title: String
    private let foregroundColor: Color

    init(title: String,
         foregroundColor: Color) {
        self.title = title
        self.foregroundColor = foregroundColor
    }

    var body: some View {
        HStack {
            Text(title)
                .padding(.leading, 20)
                .padding(.top, 20)
                .font(.headline)
                .foregroundColor(foregroundColor)
            Spacer()
        }
    }
}
