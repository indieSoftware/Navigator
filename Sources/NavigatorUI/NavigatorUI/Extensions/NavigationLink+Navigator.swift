//
//  NavigationLink+Navigator.swift
//  NavigatorUI
//
//  Created by Michael Long on 9/10/25.
//

import SwiftUI

extension NavigationLink where Destination == Never {
    /// Override for standard NavigationLink/value initializer to handle NavigationDestination's correctly.
    @MainActor
    public init<D: NavigationDestination>(value: D, @ViewBuilder label: () -> Label) {
        self.init(value: AnyNavigationDestination(value), label: label)
    }

    /// Allows for positive confirmation you're using NavigationDestination values
    @MainActor
    public init<D: NavigationDestination>(navigation value: D, @ViewBuilder label: () -> Label) {
        self.init(value: AnyNavigationDestination(value), label: label)
    }

}
