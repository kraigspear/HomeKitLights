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

    init(_ room: Room) {
        self.room = room
    }

    var body: some View {
        VStack {
            TitleView(room.name)
                .padding(.leading, 8)

            ScrollView(.horizontal) {
                HStack {
                    ForEach(room.accessories) {
                        AccessoryView($0).padding()
                    }
                }
            }.padding(.trailing, 20)
        }
    }
}

private struct TitleView: View {
    private let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("RoomText"))
                .padding(.leading, 8)
            Spacer()
        }
    }
}

private struct AccessoryView: View {
    private let accessory: Accessory

    init(_ accessory: Accessory) {
        self.accessory = accessory
    }

    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: accessory.imageName)!)
                .resizable()
                .frame(width: 44, height: 44, alignment: .center)
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

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        let room = RoomMock.livingRoom()

        return Group {
            RoomLightsView(room)
                .previewLayout(.fixed(width: 400, height: 200))
                .environment(\.colorScheme, .light)

            RoomLightsView(room)
                .previewLayout(.fixed(width: 400, height: 200))
                .environment(\.colorScheme, .dark)
        }
    }
}
