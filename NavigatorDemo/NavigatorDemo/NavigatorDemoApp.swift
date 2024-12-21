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

    let resolver = AppResolver()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.navigator, Navigator(configuration: configuration))
                .environment(\.coreDependencies, resolver)
                .environment(\.homeDependencies, resolver)
                .environment(\.settingsDependencies, resolver)
        }
    }

    var configuration: NavigationConfiguration {
        .init(restorationKey: "1.0.0", verbosity: .info)
    }
    
}
