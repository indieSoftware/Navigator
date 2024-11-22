//
//  NavigatorDemoLinks.swift
//  NavigatorDemo
//
//  Created by Michael Long on 11/21/24.
//

import Navigator
import SwiftUI

struct HomeURLHander: NavigationURLHander {
    public func handles(_ url: URL) -> [any Hashable]? {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "home" else {
            return nil
        }
        switch url.pathComponents.last {
        case "page2":
            // xcrun simctl openurl booted navigator://app/home/page2
            return [RootTabs.home, HomeDestinations.page2]
        case "page3":
            // xcrun simctl openurl booted navigator://app/home/page3
            return [RootTabs.home, HomeDestinations.page3]
        default:
            // xcrun simctl openurl booted navigator://app/home
            return [RootTabs.home]
        }
    }
}

struct SettingsURLHander: NavigationURLHander {
    public func handles(_ url: URL) -> [any Hashable]? {
        guard url.pathComponents.count > 1, url.pathComponents[1] == "settings" else {
            return nil
        }
        return [RootTabs.settings]
    }
}
