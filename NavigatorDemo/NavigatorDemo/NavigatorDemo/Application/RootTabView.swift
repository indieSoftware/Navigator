//
//  TabView.swift
//  Nav5
//
//  Created by Michael Long on 11/15/24.
//

import Navigator
import SwiftUI

enum RootTabs: Int, Identifiable, Codable {
    case home
    case settings
    var id: String { "\(self)" }
}

struct RootTabView : View {
    @SceneStorage("selectedTab") var selectedTab: RootTabs = .home
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeRootView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(RootTabs.home)
            SettingsRootView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(RootTabs.settings)
        }
        // setup tab switching
        .onNavigationReceive { (tab: RootTabs) in
            if tab == selectedTab {
                return .immediately
            }
            selectedTab = tab
            return .auto
        }
        // set authentication root from which auth dialog will be presented
        .setAuthenticationRoot()
    }
}

#Preview {
    RootTabView()
}
