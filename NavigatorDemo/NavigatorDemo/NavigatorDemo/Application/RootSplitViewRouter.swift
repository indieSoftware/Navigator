//
//  RootSplitViewRouter.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/25/25.
//

import Navigator
import SwiftUI

public struct RootSplitViewRouter: NavigationRouting {

    let navigator: Navigator

    @MainActor public func route(to destination: KnownRoutes) {
        navigator.perform(actions: actions(for: destination))
    }

    @MainActor func actions(for route: KnownRoutes) -> [NavigationAction] {
        switch route {
        case .auth:
            [
                .reset,
                .send(RootTabs.home),
                .authenticationRequired,
                .send(HomeDestinations.pageN(77))
            ]
        case .home:
            [
                .reset,
                .send(RootTabs.home)
            ]
        case .homePage2:
            [
                .dismissAny,
                .send(RootTabs.home),
                .send(HomeDestinations.page2)
            ]
        case .homePage3, .homePage2Page3:
            [
                .dismissAny,
                .send(RootTabs.home),
                .popAll(in: RootTabs.home.id),
                .send(HomeDestinations.page2),
                .send(HomeDestinations.page3)
            ]
        case .settings:
            [
                .dismissAny,
                .send(RootTabs.settings),
                .popAll(in: RootTabs.settings.id)
            ]
        default:
            [
                .reset,
                .send(RootTabs.home)
            ]
        }
    }
}
