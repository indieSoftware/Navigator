//
//  NavigatorDemoLinks.swift
//  NavigatorDemo
//
//  Created by Michael Long on 11/21/24.
//

import Navigator
import SwiftUI

struct HomeURLHander: NavigationURLHander {
    let provider: any NavigationActionProviding<KnownRoutes>
    @MainActor public func handles(_ url: URL) -> [NavigationAction]? {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "home" else {
            return nil
        }
        switch url.pathComponents.last {
        case "auth":
            // xcrun simctl openurl booted navigator://app/home/auth
            return provider.actions(for: .auth)
        case "page2":
            // xcrun simctl openurl booted navigator://app/home/page2
            return provider.actions(for: .homePage2)
        case "page3":
            // xcrun simctl openurl booted navigator://app/home/page3
            return provider.actions(for: .homePage3)
        default:
            // xcrun simctl openurl booted navigator://app/home
            return provider.actions(for: .home)
        }
    }
}

struct SettingsURLHander: NavigationURLHander {
    let provider: any NavigationActionProviding<KnownRoutes>
    @MainActor public func handles(_ url: URL) -> [NavigationAction]? {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "settings" else {
            return nil
        }
        return provider.actions(for: .settings)
    }
}
