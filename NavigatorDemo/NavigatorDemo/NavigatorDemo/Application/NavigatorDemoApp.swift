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
        let router = rootViewType.router(navigator)
        return AppResolver(navigator: navigator, router: router)
    }

    func applicationView(_ resolver: AppResolver) -> some View {
        rootViewType()
            // navigation environment
            .environment(\.navigator, resolver.navigator)
            .environment(\.router, resolver.router)
            // application dependencies
            .environment(\.coreDependencies, resolver)
            .environment(\.homeDependencies, resolver)
            .environment(\.settingsDependencies, resolver)
            // url handlers
            .onNavigationOpenURL(handlers: [
                HomeURLHander(router: resolver.router),
                SettingsURLHander(router: resolver.router)
            ])
            // receiver handler to switch application root view type
            .onNavigationReceive(assign: $rootViewType)
    }

}
