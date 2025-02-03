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

    let rootViewType: AppRootType

    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            rootViewType = .split
        } else {
            rootViewType = .tabbed
        }
    }

    var body: some Scene {
        WindowGroup {
            // we want a new application resolver and navigator for each scene
            applicationView(applicationResolver())
         }
    }

    func applicationResolver() -> AppResolver {
        let configuration: NavigationConfiguration = .init(
            restorationKey: nil, // "1.0.0",
            executionDelay: 0.3, // 0.3 - 5.0
            verbosity: .info
        )
        let navigator = Navigator(configuration: configuration)
        return AppResolver(rootViewType: rootViewType, navigator: navigator)
    }

    func applicationView(_ resolver: AppResolver) -> some View {
        // Remember that modifiers wrap their parent view or parent modifiers, which means that they work from the outside in.
        // So here we're setting up dependencies first, then navigation, then url handlers.
        rootViewType()
            // setup url handlers
            .onNavigationOpenURL(handlers: [
                SimpleURLHandler(),
                HomeURLHandler(),
                SettingsURLHandler()
            ])
            // setup navigation environment
            .environment(\.navigator, resolver.navigator)
            // provide application dependencies
            .environment(\.coreDependencies, resolver)
            .environment(\.homeDependencies, resolver)
            .environment(\.settingsDependencies, resolver)
    }

}
