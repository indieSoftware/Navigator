//
//  RootTabViewRouter.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/25/25.
//

import NavigatorUI
import SwiftUI

public struct RootTabViewRouter: NavigationRouteHandling {

    @MainActor public func route(to route: KnownRoutes, with navigator: Navigator) {
        switch route {
        case .auth:
            navigator.perform(
                .reset,
                .send(RootTabs.home),
                .authenticationRequired,
                .send(HomeDestinations.pageN(77))
            )
        case .home:
            navigator.perform(
                .reset,
                .send(RootTabs.home)
            )
        case .homePage2:
            navigator.perform(
                .dismissAny,
                .send(RootTabs.home),
                .send(HomeDestinations.page2)
            )
        case .homePage3, .homePage2Page3:
            navigator.perform(
                .dismissAny,
                .send(RootTabs.home),
                .popAll(in: RootTabs.home.id),
                .send(HomeDestinations.page2),
                .send(HomeDestinations.page3)
            )
        case .homePage2Page3PageN(let n):
            navigator.perform(
                .dismissAny,
                .send(RootTabs.home),
                .popAll(in: RootTabs.home.id),
                .send(HomeDestinations.page2),
                .send(HomeDestinations.page3),
                .send(HomeDestinations.pageN(n))
            )
        case .settings:
            navigator.perform(
                .dismissAny,
                .send(RootTabs.settings),
                .popAll(in: RootTabs.settings.id)
            )
        case .settingsPage2:
            navigator.perform(
                .dismissAny,
                .send(RootTabs.settings),
                .popAll(in: RootTabs.settings.id),
                .send(SettingsDestinations.page2)
            )
        case .settingsPage3:
            navigator.perform(
                .dismissAny,
                .send(RootTabs.settings),
                .popAll(in: RootTabs.settings.id),
                .send(SettingsDestinations.page3)
            )
        case .external:
            navigator.push(HomeDestinations.external)
            //        default:
            //            navigator.perform(
            //                .reset,
            //                .send(RootTabs.home)
            //            )
        }
    }
}
