//
//  RootTabs.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/27/25.
//

import Navigator
import SwiftUI

enum RootTabs: Int, Codable {
    case home
    case settings
}

extension RootTabs: Identifiable {

    static var tabs: [RootTabs] {
        [.home, .settings]
    }

    static var sidebar: [RootTabs] {
        [.home, .settings]
    }

    var id: String {
        "\(self)"
    }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .settings:
            "Settings"
        }
    }

    var image: String {
        switch self {
        case .home:
            "house"
        case .settings:
            "gear"
        }
    }

}

extension RootTabs: NavigationDestination {
    var view: some View {
        switch self {
        case .home:
            HomeRootView()
        case .settings:
            SettingsRootView()
        }
    }
}
