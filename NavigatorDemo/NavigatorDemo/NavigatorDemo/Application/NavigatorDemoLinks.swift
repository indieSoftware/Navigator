//
//  NavigatorDemoLinks.swift
//  NavigatorDemo
//
//  Created by Michael Long on 11/21/24.
//

import Navigator
import SwiftUI

struct HomeURLHander: NavigationURLHander {
    let router: any NavigationRouting<KnownRoutes>
    @MainActor public func handles(_ url: URL) -> Bool {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "home" else {
            return false
        }
        switch url.pathComponents.last {
        case "auth":
            // xcrun simctl openurl booted navigator://app/home/auth
            router.route(to: .auth)
        case "page2":
            // xcrun simctl openurl booted navigator://app/home/page2
            router.route(to: .homePage2)
        case "page3":
            // xcrun simctl openurl booted navigator://app/home/page3
            router.route(to: .homePage3)
        default:
            // xcrun simctl openurl booted navigator://app/home
            router.route(to: .home)
        }
        return true
    }
}

struct SettingsURLHander: NavigationURLHander {
    let router: any NavigationRouting<KnownRoutes>
    @MainActor public func handles(_ url: URL) -> Bool {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "settings" else {
            return false
        }
        router.route(to: .settings)
        return true
    }
}
