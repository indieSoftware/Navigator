//
//  TabView.swift
//  Nav5
//
//  Created by Michael Long on 11/15/24.
//

import Navigator
import SwiftUI

struct RootTabView : View {
    @SceneStorage("selectedTab") var selectedTab: RootTabs = .home
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(RootTabs.tabs) { tab in
                tab()
                    .tabItem { Label(tab.title, systemImage: tab.image) }
                    .tag(tab)
            }
        }
        // setup tab switching
        .onNavigationReceive { (tab: RootTabs) in
            if tab == selectedTab {
                return .immediately
            }
            selectedTab = tab
            return .auto
        }
        // set route handler for this view type
        .onNavigationRoute(RootTabViewRouter())
        // set authentication root from which auth dialog will be presented
        .setAuthenticationRoot()
    }
}

#Preview {
    RootTabView()
}
