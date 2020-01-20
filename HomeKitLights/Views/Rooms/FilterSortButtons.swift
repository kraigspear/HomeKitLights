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
            FilterButtons(viewModel: viewModel)
            SortButtons(viewModel: viewModel)
        }
    }
}

struct FilterButtons: View {
    @ObservedObject var viewModel: RoomsViewModel

    init(viewModel: RoomsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TitleView(title: "Filter",
                      foregroundColor: .primary)
            Picker(selection:
                $viewModel.filterIndex,
                   label: Text("Filter")) {
                Text("All").tag(RoomFilter.all.rawValue)
                Text("Off").tag(RoomFilter.off.rawValue)
                Text("On").tag(RoomFilter.on.rawValue)
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct SortButtons: View {
    @ObservedObject var viewModel: RoomsViewModel

    var body: some View {
        VStack {
            TitleView(title: "Sort",
                      foregroundColor: .primary)
            Picker(selection:
                $viewModel.sortIndex,
                   label: Text("Sort")) {
                Text("A-Z").tag(RoomSort.alphabetical.rawValue)
                Text("Last Modified").tag(RoomSort.lastUpdated.rawValue)
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}
