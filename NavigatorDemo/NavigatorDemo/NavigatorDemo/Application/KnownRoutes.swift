//
//  KnownCheckpoins.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/19/25.
//

import Navigator
import SwiftUI

public enum KnownRoutes: Hashable {
    case auth
    case home
    case homePage2
    case homePage3
    case homePage2Page3
    case settings
    case settingsPage2
    case settingsPage3
}

extension EnvironmentValues {
    @Entry public var routeActionProvider: any NavigationActionProviding<KnownRoutes> = EmptyNavigationActionProvider()
}
