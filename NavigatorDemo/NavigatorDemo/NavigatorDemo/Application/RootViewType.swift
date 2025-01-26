//
//  RootViewType.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/26/25.
//

import Navigator
import SwiftUI

enum RootViewType {
    case tabbed
    case split
}

extension RootViewType: NavigationDestination {

    var view: some View {
        switch self {
        case .tabbed:
            RootTabView()
        case .split:
            RootSplitView()
        }
    }

    func router(_ navigator: Navigator) -> any NavigationRouting<KnownRoutes> {
        switch self {
        case .tabbed:
            TabViewNavigationRouter(navigator: navigator)
        case .split:
            SplitViewNavigationRouter(navigator: navigator)
        }
    }
    
}
