//
//  NavigatorDemoApp.swift
//  NavigatorDemo
//
//  Created by Michael Long on 11/19/24.
//

import Navigator
import SwiftUI

@main
struct NavigatorDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.navigator, Navigator(configuration: configuration))
        }
    }

    var configuration: NavigationConfiguration {
        NavigationConfiguration(
            linkHanders: [
                HomeLinkHander(),
                SettingsLinkHander()
            ]
        )
    }
}
