//
//  ContentView.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import SwiftUI

struct LightsView: View {
    @ObservedObject var viewModel: LightsViewModel

    init(viewModel: LightsViewModel) {
        self.viewModel = viewModel
    }

    init() {
        self.init(viewModel: LightsViewModel())
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ForEach(viewModel.rooms) {
                    RoomRow(room: $0)
                }
                Spacer()
            }.onAppear { self.viewModel.onAppear() }
            .navigationBarTitle(Text("HomeKit"), displayMode: .large)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let homeKitAccessible = HomeKitAccessMock()
        homeKitAccessible.whenHasRooms()
        let viewModel = LightsViewModel(homeKitAccessible: homeKitAccessible)
        return LightsView(viewModel: viewModel)
    }
}
