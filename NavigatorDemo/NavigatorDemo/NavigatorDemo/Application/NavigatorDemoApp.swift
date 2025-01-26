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
                .onNavigationReceive(assign: $rootViewType)
        }
    }

    func applicationResolver() -> AppResolver {
        let configuration: NavigationConfiguration = .init(
            restorationKey: nil, // "1.0.0",
            executionDelay: 0.1, // 0.1 - 1.0
            verbosity: .info
        )
        let navigator = Navigator(configuration: configuration)
        return AppResolver(navigator: navigator)
    }

    func applicationView(_ resolver: AppResolver) -> some View {
        rootViewType()
            .environment(\.navigator, resolver.navigator)
            .environment(\.coreDependencies, resolver)
            .environment(\.homeDependencies, resolver)
            .environment(\.settingsDependencies, resolver)
    }

}

enum RootViewType {
    case tabbed
    case split
}

extension RootViewType: NavigationDestination {
    var view: some View {
        switch self {
        case .tabbed:
            RootTabView()
                .environment(\.routeActionProvider, KnownRouteTabProvider())
        case .split:
            RootSplitView()
                .environment(\.routeActionProvider, KnownRouteSplitViewProvider())
        }
    }
}
