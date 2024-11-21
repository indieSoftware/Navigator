//
//  TabView.swift
//  Nav5
//
//  Created by Michael Long on 11/15/24.
//

import SwiftUI

enum RootTabs: CaseIterable, Identifiable {
    case home
    case settings
    var id: Self { self }
}

struct RootTabView : View {
    @State var selectedTab: RootTabs = .home
    @Environment(\.navigator) var navigator
    var body: some View {
        TabView(selection: $selectedTab) {
            RootHomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(RootTabs.home)
            RootSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(RootTabs.settings)
        }
        .onNavigationReceive { (tab: RootTabs) in
            navigator.dismissAll()
            selectedTab = tab
            return .auto
        }
        .onOpenURL { url in
            navigator.openURL(url)
        }
    }
}

#Preview {
    RootTabView()
}
