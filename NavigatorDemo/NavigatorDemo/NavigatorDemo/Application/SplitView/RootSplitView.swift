//
//  RootSplitView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/25/25.
//

import Navigator
import SwiftUI

struct RootSplitView: View {
    @State var selectedTab: RootTabs! = .home
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                Section("Menu") {
                    ForEach(RootTabs.sidebar) { tab in
                        NavigationLink(value: tab) {
                            Label(tab.title, systemImage: tab.image)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(200)
        } detail: {
            selectedTab()
        }
        .onNavigationReceive { (tab: RootTabs) in
            if tab == selectedTab {
                return .immediately
            }
            selectedTab = tab
            return .after(0.8) // switching root views needs a little more time
        }
    }
}
