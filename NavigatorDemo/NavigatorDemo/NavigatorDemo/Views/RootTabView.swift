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
    @Environment(\.routeActionProvider) var routeActionProvider
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeRootView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(RootTabs.home)
            SettingsRootView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(RootTabs.settings)
        }
        .onNavigationReceive { (tab: RootTabs) in
            if tab == selectedTab {
                return .immediately
            }
            selectedTab = tab
            return .auto
        }
        .onNavigationReceive { (route: KnownRoutes, navigator) in
            .replacing(routeActionProvider.actions(for: route))
        }
        .onNavigationOpenURL(handlers: [
            HomeURLHander(provider: routeActionProvider),
            SettingsURLHander(provider: routeActionProvider)
        ])
        .setAuthenticationRoot()
    }
}

#Preview {
    RootTabView()
}
