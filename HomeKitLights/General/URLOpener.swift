//
//  URLOpener.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/16/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import UIKit

protocol URLOpenable {
    func open(_ url: URL)
}

final class URLOpener: URLOpenable {
    func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
