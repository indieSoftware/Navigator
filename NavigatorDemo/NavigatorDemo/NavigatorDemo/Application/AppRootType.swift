//
//  RootViewType.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/26/25.
//

import NavigatorUI
import SwiftUI

enum AppRootType: Int {
    case tabbed
    case split
}

extension AppRootType: NavigationDestination {

    // Provides the correct view for this type
    var body: some View {
        switch self {
        case .tabbed:
            RootTabView()

        case .split:
            RootSplitView()
        }
    }
    
}

struct ToogleAppRootType: Hashable {}
