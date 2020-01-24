//
//  RoomLightsView.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/9/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import SwiftUI

// The only supported accessory is a light. Using a typealias to make it more readable
typealias Light = Accessory
typealias Lights = [Light]

// MARK: - RoomLightsView

/// View containing the room, brightness, indicators for each light in a room
struct RoomLightsView: View {
    // MARK: - Members

    /// Room that is being displayed
    private let room: Room

    /// ViewModel backing this View.
    @ObservedObject var viewModel: RoomLightsViewModel

    // MARK: - Init

    /// Returns a newly initialized RoomLightsView with the room and ViewModel
    /// - Parameters:
    ///   - room: Room that is being viewed
    ///   - viewModel: ViewModel containing state
    init(_ room: Room,
         viewModel: RoomLightsViewModel) {
        self.room = room
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                TitleView(title: room.name, foregroundColor: Color("RoomText"))

                LightsView(viewModel: viewModel,
                           accessories: room.lights)
                    .frame(height: 50, alignment: .center)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    .padding(.top, 20)
                    .padding(.bottom, viewModel.areLightsOn ? 0 : 20)

                if viewModel.areLightsOn {
                    BrightnessView(viewModel: viewModel)
                        .frame(width: nil, height: 40, alignment: .center)
                        .padding(.top, 20)
                }
                Spacer()
            }.gesture(TapGesture()
                .onEnded { _ in self.viewModel.toggle() }
            )

            VStack {
                HStack {
                    Spacer()
                    ActivityView(isActive: $viewModel.isBusy)
                        .padding()
                }
                Spacer()
            }
        }.cornerRadius(20)
    }
}

private struct LightsView: View {
    @ObservedObject var viewModel: RoomLightsViewModel
    let lights: Lights

    init(viewModel: RoomLightsViewModel,
         accessories: Lights) {
        self.viewModel = viewModel
        lights = accessories
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(lights) {
                    LightView($0, viewModel: self.viewModel).padding()
                }
            }
        }
    }
}

private struct LightView: View {
    private let light: Light
    @ObservedObject private var viewModel: RoomLightsViewModel

    private static let imageSize: CGFloat = 70.0

    init(_ light: Light,
         viewModel: RoomLightsViewModel) {
        self.light = light
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Image(viewModel.imageName)
                .resizable()
                .frame(width: LightView.imageSize,
                       height: LightView.imageSize,
                       alignment: .center)
                .aspectRatio(contentMode: .fill)
                .opacity(Double(viewModel.imageOpacity))
        }
    }
}

private struct BrightnessView: View {
    @ObservedObject var viewModel: RoomLightsViewModel

    init(viewModel: RoomLightsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Slider(value: $viewModel.brightness,
               in: 0 ... 100,
               step: 0.1)
            .padding()
    }
}

// MARK: - Previews

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        let room = RoomMock.livingRoom()

        let homeKit = HomeKitAccessMock()
        let roomData = RoomDataAccessibleMock()
        let hapticFeedbackMock = HapticFeedbackMock()
        let roomLightsViewModel = RoomLightsViewModel(room: room,
                                                      homeKitAccessible: homeKit,
                                                      roomDataAccessible: roomData,
                                                      hapticFeedback: hapticFeedbackMock)

        let roomLightsViewModelNotBright = RoomLightsViewModel(room: RoomMock.roomNoBrightness(),
                                                               homeKitAccessible: homeKit,
                                                               roomDataAccessible: roomData,
                                                               hapticFeedback: hapticFeedbackMock)

        return Group {
            RoomLightsView(room,
                           viewModel: roomLightsViewModel)
                .roomStyle()
                .previewLayout(.fixed(width: 400, height: 200))
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light")

            RoomLightsView(room,
                           viewModel: roomLightsViewModel)
                .roomStyle()
                .previewLayout(.fixed(width: 400, height: 200))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark")

            RoomLightsView(room,
                           viewModel: roomLightsViewModelNotBright)
                .roomStyle()
                .previewLayout(.fixed(width: 400, height: 200))
                .environment(\.colorScheme, .dark)
                .previewDisplayName("No Brightness")
        }
    }
}
