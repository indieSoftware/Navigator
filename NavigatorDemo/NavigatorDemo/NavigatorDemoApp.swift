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

    let resolver: AppResolver = {
        // create root navigator
        let configuration = NavigationConfiguration(restorationKey: nil /* "1.0.0" */, verbosity: .info)
        let navigator = Navigator(configuration: configuration)
        // create resolver with root navigator for deep linking and internal linking support
        return AppResolver(navigator: navigator)
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.navigator, resolver.navigator)
                .environment(\.coreDependencies, resolver)
                .environment(\.homeDependencies, resolver)
                .environment(\.settingsDependencies, resolver)
        }
    }
    
}
