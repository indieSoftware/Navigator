//
//  NavigationLink+Navigator.swift
//  NavigatorUI
//
//  Created by Michael Long on 9/10/25.
//

import SwiftUI

extension NavigationLink where Destination == Never {

    /// Overrides initializer for standard NavigationLink/value initializer to handle NavigationDestination's correctly.
    @MainActor
    public init<D: NavigationDestination>(to destination: D, @ViewBuilder label: () -> Label) {
        self.init(value: AnyNavigationDestination(destination), label: label)
    }

}
