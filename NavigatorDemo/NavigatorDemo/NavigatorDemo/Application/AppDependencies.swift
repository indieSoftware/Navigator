//
//  AppDependencies.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/24/25.
//

import Navigator
import SwiftUI

//
// APPLICATION DEPENDENCY RESOLVER
//

// Application aggregates all known module dependencies
typealias AppDependencies = CoreDependencies
    & HomeDependencies
    & SettingsDependencies

// Make the application's dependency resolver
class AppResolver: AppDependencies {

    // root view type
    let rootViewType: AppRootType

    // root navigator
    let navigator: Navigator

    // ensure we have dependency cache in scope
    let cache: DependencyCache = .init()

    // initializer
    init(rootViewType: AppRootType, navigator: Navigator) {
        self.rootViewType = rootViewType
        self.navigator = navigator
    }

    // Missing default dependencies forces app to provide them.
    func analytics() -> any AnalyticsService {
        cached { ThirdPartyAnalyticsService() }
    }

    // Home needs an external view from somewhere. Provide it.
    @MainActor func homeExternalViewProvider() -> any NavigationViewProviding<HomeExternalViews> {
        NavigationViewProvider {
            switch $0 {
            case .external:
                SettingsDestinations.external()
            }
        }
    }

    // Home feature wants to be able to route to settings feature, app knows how app is structured, so...
    @MainActor func homeExternalRouter() -> any NavigationRouting<HomeExternalRoutes> {
        NavigationRouter(navigator) { route in
            // Map external routes required by Home feature to known application routes
            switch route {
            case .settingsPage2:
                self.navigator.perform(route: KnownRoutes.settingsPage2)
            case .settingsPage3:
                self.navigator.perform(route: KnownRoutes.settingsPage3)
            }
        }
    }
    
    // Missing default provides proper key
    var settingsKey: String { "actual" }
}
