//
//  AppRootDestinations.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/26/25.
//

import NavigatorUI
import SwiftUI

enum AppRootDestinations: Int {
    case demo
}

extension AppRootDestinations: NavigationDestination {

    // Provides the correct view for this type
    var body: some View {
        Text("Root View Demo")
            .navigationTitle("Root")
    }

    var method: NavigationMethod {
        .managedSheet
    }
}
