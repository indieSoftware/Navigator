//
//  KnownRouteTabProvider.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/25/25.
//

import Navigator
import SwiftUI

struct KnownRouteTabProvider: NavigationActionProviding {
    func actions(for route: KnownRoutes) -> [NavigationAction] {
        return switch route {
        case .auth: [
            .reset,
            .send(RootTabs.home),
            .authenticationRequired,
            .send(HomeDestinations.pageN(77))
        ]
        case .home: [
            .reset,
            .send(RootTabs.home)
        ]
        case .homePage2: [
            .dismissAny,
            .send(RootTabs.home),
            .send(HomeDestinations.page2)
        ]
        case .homePage3, .homePage2Page3: [
            .dismissAny,
            .send(RootTabs.home),
            .popAll(in: RootTabs.home.id),
            .send(HomeDestinations.page2),
            .send(HomeDestinations.page3)
        ]
        default: [
            .reset,
            .send(RootTabs.home)
        ]
        }
    }
}
