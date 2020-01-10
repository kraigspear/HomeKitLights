//
//  LightsView.swift
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
            ScrollView {
                VStack {
                    TitleView(title: "Rooms")
                        .padding(.bottom, 8)

                    ForEach(viewModel.rooms) {
                        RoomLightsView($0, viewModel: self.viewModel)
                            .frame(minHeight: 150, idealHeight: 150,
                                   alignment: .center)
                            .background(Color("RoomBackground"))
                            .cornerRadius(20)
                            .padding(.leading, 14)
                            .padding(.trailing, 14)
                            .padding(.bottom, 12)
                    }

                    Spacer()
                }
            }
            .onAppear { self.viewModel.onAppear() }
            .navigationBarTitle(Text("Lights"), displayMode: .large)
        }
    }
}

private struct TitleView: View {
    private let title: String

    init(title: String) {
        self.title = title
    }

    var body: some View {
        HStack {
            Text(title)
                .padding(.leading, 20)
                .padding(.top, 20)
                .font(.headline)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let homeKitPreview = HomeKitAccessPreview()
        homeKitPreview.whenHasRooms()
        let viewModel = LightsViewModel(homeKitAccessible: homeKitPreview)

        return Group {
            LightsView(viewModel: viewModel)
                .environment(\.colorScheme, .light)

            LightsView(viewModel: viewModel)
                .environment(\.colorScheme, .dark)
        }
    }
}
