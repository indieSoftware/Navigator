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

    @State var rootViewType: RootViewType = .tabbed

    var body: some Scene {
        WindowGroup {
            // we want a new application resolver and navigator for each scene
            applicationView(applicationResolver())
         }
    }

    func applicationResolver() -> AppResolver {
        let configuration: NavigationConfiguration = .init(
            restorationKey: nil, // "1.0.0",
            executionDelay: 0.1, // 0.1 - 1.0
            verbosity: .info
        )
        let navigator = Navigator(configuration: configuration)
        return AppResolver(rootViewType: rootViewType, navigator: navigator)
    }

    func applicationView(_ resolver: AppResolver) -> some View {
        rootViewType()
            // setup url handlers
            .onNavigationOpenURL(handlers: [
                SimpleURLHandler(),
                HomeURLHandler(router: resolver.router),
                SettingsURLHandler(router: resolver.router)
            ])
            // setup receive handler to switch application root view type
            .onNavigationReceive(assign: $rootViewType)
             // setup navigation environment
            .environment(\.navigator, resolver.navigator)
            .environment(\.router, resolver.router)
            // provide application dependencies
            .environment(\.coreDependencies, resolver)
            .environment(\.homeDependencies, resolver)
            .environment(\.settingsDependencies, resolver)
    }

}
