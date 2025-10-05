//
//  KnownRoutes.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/19/25.
//

import NavigatorUI
import SwiftUI

nonisolated public enum KnownRoutes: NavigationRoutes {
    case auth
    case home
    case homePage2
    case homePage3
    case homePage2Page3
    case homePage2Page3PageN(Int)
    case settings
    case settingsPage2
    case settingsPage3
    case external
}
