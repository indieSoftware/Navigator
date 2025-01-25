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

    // root navigator
    let navigator: Navigator

    // initializer
    init(navigator: Navigator) {
        self.navigator = navigator
    }

    // need one per app
    let analyticsService = ThirdPartyAnalyticsService()

    // Missing default dependencies forces app to provide them.
    func analytics() -> any AnalyticsService {
        analyticsService
    }

    // Home needs an external view from somewhere. Provide it.
    @MainActor func homeExternalViewProvider() -> any ExternalNavigationViewProviding<HomeExternalViews> {
        ExternalNavigationViewProvider {
            switch $0 {
            case .external:
                SettingsDestinations.external()
            }
        }
    }

    // Home feature wants to be able to route to settings feature, app knows how app is structured, so...
    @MainActor func homeExternalRouter() -> any ExternalNavigationRouting<HomeExternalRoutes> {
        ExternalNavigationRouter {
            switch $0 {
            case .settingsPage2:
                // Demonstrate routing with navigation actions
                self.navigator.perform(actions: [
                    .dismissAny,
                    .send(RootTabs.settings),
                    .with(navigator: RootTabs.settings.id) {
                        $0.popAll()
                        $0.push(SettingsDestinations.page2)
                    },
                ])
            case .settingsPage3:
                // Demonstrate routing sending raw navigation values
                self.navigator.send(values: [
                    NavigationAction.dismissAny,
                    RootTabs.settings,
                    NavigationAction.with(navigator: RootTabs.settings.id) {
                        $0.popAll()
                        $0.push(SettingsDestinations.page3)
                    },
                ])
            }
        }
    }
    
    // Missing default provides proper key
    var settingsKey: String { "actual" }
}
