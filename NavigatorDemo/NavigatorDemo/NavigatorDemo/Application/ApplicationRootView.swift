//
//  ApplicationRootView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 7/9/25.
//

import NavigatorUI
import SwiftUI

struct ApplicationRootView: View {

    // SceneStorage must exist within a view
    @SceneStorage("appRootType") var appRootType: AppRootType = UIDevice.current.userInterfaceIdiom == .pad ? .split : .tabbed

    var body: some View {
        applicationView(AppResolver(navigator: applicationNavigator()))
    }

    func applicationNavigator() -> Navigator {
        let configuration: NavigationConfiguration = .init(
            restorationKey: nil, // "1.0.0",
            executionDelay: 0.4, // 0.3 - 5.0
            verbosity: .info,
            autoDestinationMode: true
        )
        return Navigator(configuration: configuration)
    }

    func applicationView(_ resolver: AppResolver) -> some View {
        // Remember that modifiers wrap their parent view or parent modifiers, which means that they work from the outside in.
        // So here we're setting up dependencies first, then navigation, then url handlers.
    appRootType
        // setup url handlers
        .onNavigationOpenURL(
            SimpleURLHandler(),
            HomeURLHandler(),
            SettingsURLHandler()
        )
        // provide requested feature views
        .onNavigationProvidedView(HomeExternalViews.self) { _ in
            SettingsExternalView() // only one for this type
        }
        // provide missing view from HomeDestinations
        .onNavigationProvidedView { (d: HomeDestinations) in
            switch d {
            case .external2:
                SettingsExternalView()
            default:
                d
            }
        }
        // toggle root view type
        .onNavigationReceive { (_: ToogleAppRootType) in
            self.appRootType = appRootType == .split ? .tabbed : .split
            return .auto
        }
        // enable presentation options on the navigation root (this must be *inside* the root navigator)
        .navigationAutoReceive(AppRootDestinations.self)
        // setup known mapping for all views
        .navigationMap { destination in
            switch destination {
            case HomeDestinations.mapped:
                HomeDestinations.pageN(99)
            default:
                destination
            }
        }
        // setup managed navigation root
        .navigationRoot(resolver.navigator)
            // provide application dependencies
            .environment(\.coreDependencies, resolver)
            .environment(\.homeDependencies, resolver)
            .environment(\.settingsDependencies, resolver)
    }

}
