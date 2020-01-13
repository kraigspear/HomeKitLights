//
//  FilterSortButtons.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/10/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import Foundation
import SwiftUI

struct FilterSortButtons: View {
    @ObservedObject var viewModel: RoomsViewModel

    init(viewModel: RoomsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TitleView(title: "Filter",
                      foregroundColor: .primary)
            Picker(selection: $viewModel.filterIndex,
                   label: Text("Filter")) {
                Text("All").tag(RoomFilter.all.rawValue)
                Image(systemName: "lightbulb").tag(RoomFilter.off.rawValue)
                Image(systemName: "lightbulb.fill").tag(RoomFilter.on.rawValue)
                Image(systemName: "clock.fill").tag(RoomFilter.off.rawValue)
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}
