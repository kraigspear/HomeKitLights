//
//  RoomLightsView.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/9/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import SwiftUI

// MARK: - RoomLightsView

struct RoomLightsView: View {
    private let room: Room
    @ObservedObject var viewModel: RoomLightsViewModel

    init(_ room: Room,
         viewModel: RoomLightsViewModel) {
        self.room = room
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            VStack {
                TitleView(title: room.name, foregroundColor: Color("RoomText"))
                    .padding(.leading, 8)

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(room.accessories) {
                            AccessoryView($0, viewModel: self.viewModel).padding()
                        }
                    }
                }.padding(.trailing, 20)
            }.gesture(TapGesture()
                .onEnded { _ in self.viewModel.toggle() }
            )

            VStack {
                Spacer()
                HStack {
                    Spacer()

                    ActivityView(isActive: $viewModel.isBusy)

                    Spacer()
                }
                Spacer()
            }
        }
    }
}

private struct AccessoryView: View {
    private let accessory: Accessory
    private let viewModel: RoomLightsViewModel

    private static let imageSize: CGFloat = 54.0

    init(_ accessory: Accessory,
         viewModel: RoomLightsViewModel) {
        self.accessory = accessory
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: accessory.imageName)!)
                .resizable()
                .frame(width: AccessoryView.imageSize,
                       height: AccessoryView.imageSize,
                       alignment: .center)
                .aspectRatio(contentMode: .fit)
        }
    }
}

private extension Accessory {
    var imageName: String {
        isOn ? "LightOn" : "LightOff"
    }
}

// MARK: - Previews

// struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        let room = RoomMock.livingRoom()
//
//        let homeKitAccessible = HomeKitAccess()
//        let lightsViewModel = LightsViewModel(homeKitAccessible: <#T##HomeKitAccessible#>)
//
//        return Group {
//            RoomLightsView(room, viewModel: <#LightsViewModel#>)
//                .previewLayout(.fixed(width: 400, height: 200))
//                .environment(\.colorScheme, .light)
//
//            RoomLightsView(room)
//                .previewLayout(.fixed(width: 400, height: 200))
//                .environment(\.colorScheme, .dark)
//        }
//    }
// }
