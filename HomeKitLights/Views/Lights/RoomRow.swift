//
//  RoomRow.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import os.log
import SwiftUI

struct RoomRow: View {
    private let log = Log.lightsView

    private let room: Room

    init(room: Room) {
        os_log("RoomRow: %s",
               log: log,
               type: .debug,
               room.name)

        self.room = room
    }

    var body: some View {
        VStack {
            TileTitleView(title: room.name)
        }
    }
}

/// Title to show over a section of tiles
private struct TileTitleView: View {
    private let title: String

    init(title: String) {
        self.title = title
    }

    var body: some View {
        Text(title).font(.largeTitle)
            .foregroundColor(.secondary)
    }
}

struct RoomRow_Previews: PreviewProvider {
    static var previews: some View {
        return RoomRow(room: RoomMock.livingRoom())
    }
}
