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
            // we want a new application resolver and navigator for each scene
            applicationView(applicationResolver())
        }
    }

    func applicationResolver() -> AppResolver {
        let configuration: NavigationConfiguration = .init(
            restorationKey: nil, // "1.0.0",
            executionDelay: 0.1, // 0.01 - 1.0
            verbosity: .info
        )
        let navigator = Navigator(configuration: configuration)
        return AppResolver(navigator: navigator)
    }

    func applicationView(_ resolver: AppResolver) -> some View {
        RootTabView()
            .environment(\.navigator, resolver.navigator)
            .environment(\.coreDependencies, resolver)
            .environment(\.homeDependencies, resolver)
            .environment(\.settingsDependencies, resolver)
    }

}
