//
//  NavigatorDemoLinks.swift
//  NavigatorDemo
//
//  Created by Michael Long on 11/21/24.
//

import Navigator
import SwiftUI

// Illustrates parsing a URL and directly sending actions to navigator
struct SimpleURLHandler: NavigationURLHandler {
    @MainActor public func handles(_ url: URL, with navigator: Navigator) -> Bool {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "simple", url.pathComponents.last == "sheet" else {
            return false
        }
        // xcrun simctl openurl booted navigator://app/simple/sheet
        navigator.perform(actions: [
            .reset,
            .send(RootTabs.home),
            .send(HomeDestinations.presented1),
        ])
        return true
    }
}

// Illustrates parsing a URL and mapping actions to a router
struct HomeURLHandler: NavigationURLHandler {
    let router: any NavigationRouting<KnownRoutes>
    @MainActor public func handles(_ url: URL, with navigator: Navigator) -> Bool {
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

// Illustrates parsing a URL and mapping actions to a router
struct SettingsURLHandler: NavigationURLHandler {
    let router: any NavigationRouting<KnownRoutes>
    @MainActor public func handles(_ url: URL, with navigator: Navigator) -> Bool {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "settings" else {
            return false
        }
        router.route(to: .settings)
        return true
    }
}
