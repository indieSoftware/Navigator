//
//  NavigationLink+Navigator.swift
//  NavigatorUI
//
//  Created by Michael Long on 9/10/25.
//

import SwiftUI

extension NavigationLink where Destination == Never {

    /// Creates a navigation link that pushes a ``NavigationDestination`` onto
    /// the current stack, integrating with ``ManagedNavigationStack`` and
    /// ``Navigator``.
    ///
    /// Use this initializer when the destination is a ``NavigationDestination``
    /// type so that NavigatorUI can present it correctly within a managed stack.
    ///
    /// ```swift
    /// struct ItemList: View {
    ///     var body: some View {
    ///         List(items) { item in
    ///             NavigationLink(to: ItemDestination.details(item)) {
    ///                 Text(item.title)
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - destination: The navigation destination to present when the link is tapped.
    ///   - label: A view builder that produces the link's label.
    @MainActor
    public init<D: NavigationDestination>(to destination: D, @ViewBuilder label: () -> Label) {
        self.init(value: AnyNavigationDestination(destination), label: label)
    }

}
