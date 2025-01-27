//
//  RootViewType.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/26/25.
//

import Navigator
import SwiftUI

enum AppRootType {
    case tabbed
    case split
}

extension AppRootType: NavigationDestination {

    // Provides the correct view for this type
    var view: some View {
        switch self {
        case .tabbed:
            RootTabView()
        case .split:
            RootSplitView()
        }
    }

    // Illustrates providing the correct router since application structure could change for each type
    func router(_ navigator: Navigator) -> any NavigationRouting<KnownRoutes> {
        switch self {
        case .tabbed:
            RootTabViewRouter(navigator: navigator)
        case .split:
            RootSplitViewRouter(navigator: navigator)
        }
    }
    
}
