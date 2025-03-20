//
//  NavigatorDemoLinks.swift
//  NavigatorDemo
//
//  Created by Michael Long on 11/21/24.
//

import NavigatorUI
import SwiftUI

// Illustrates parsing a URL and directly sending actions to navigator
struct SimpleURLHandler: NavigationURLHandler {
    @MainActor public func handles(_ url: URL, with navigator: Navigator) -> Bool {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "simple", url.pathComponents.last == "sheet" else {
            return false
        }
        // xcrun simctl openurl booted navigator://app/simple/sheet
        navigator.perform(
            .reset,
            .send(RootTabs.home),
            .send(HomeDestinations.presented1)
        )
        return true
    }
}

// Illustrates parsing a URL and mapping actions to a route
struct HomeURLHandler: NavigationURLHandler {
    @MainActor public func handles(_ url: URL, with navigator: Navigator) -> Bool {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "home" else {
            return false
        }
        switch url.pathComponents.last {
        case "auth":
            // xcrun simctl openurl booted navigator://app/home/auth
            navigator.perform(route: KnownRoutes.auth)
        case "page2":
            // xcrun simctl openurl booted navigator://app/home/page2
            navigator.perform(route: KnownRoutes.homePage2)
        case "page3":
            // xcrun simctl openurl booted navigator://app/home/page3
            navigator.perform(route: KnownRoutes.homePage3)
        default:
            // xcrun simctl openurl booted navigator://app/home
            navigator.perform(route: KnownRoutes.home)
        }
        return true
    }
}

// Illustrates parsing a URL and mapping actions to a router
struct SettingsURLHandler: NavigationURLHandler {
    @MainActor public func handles(_ url: URL, with navigator: Navigator) -> Bool {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "settings" else {
            return false
        }
        navigator.perform(route: KnownRoutes.settings)
        return true
    }
}
