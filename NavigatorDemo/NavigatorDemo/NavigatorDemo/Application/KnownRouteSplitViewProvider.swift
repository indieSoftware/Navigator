//
//  KnownRouteSplitViewProvider.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/25/25.
//

import Navigator
import SwiftUI

struct KnownRouteSplitViewProvider: NavigationActionProviding {
    func actions(for route: KnownRoutes) -> [NavigationAction] {
        return switch route {
        case .auth:
            // xcrun simctl openurl booted navigator://app/home/auth
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
            // xcrun simctl openurl booted navigator://app/home/page2
            [
                .dismissAny,
                .send(RootTabs.home),
                .send(HomeDestinations.page2)
            ]
        case .homePage3:
            // xcrun simctl openurl booted navigator://app/home/page3
            [
                .dismissAny,
                .send(RootTabs.home),
                .popAll(in: RootTabs.home.id),
                .send(HomeDestinations.page2),
                .send(HomeDestinations.page3)
            ]
        default:
            // xcrun simctl openurl booted navigator://app/home
            [
                .reset,
                .send(RootTabs.home)
            ]
        }
    }
}
