//
//  NavigationViewProviding.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI

/// A marker protocol for values that represent destinations in a navigation
/// view provider.
public protocol NavigationViews: Hashable {}

/// A type that can build SwiftUI views for navigation destinations.
///
/// Conforming types map strongly-typed destination values to concrete `AnyView`
/// instances that can be presented by a `Navigator` or higher-level container.
public protocol NavigationViewProviding<D> {
    associatedtype D: NavigationViews

    /// Returns a view for the provided destination.
    ///
    /// - Parameter destination: The destination to build a view for.
    /// - Returns: A type-erased view that renders the destination.
    func view(for destination: D) -> AnyView
}

/// A simple view provider that uses a `ViewBuilder` closure to construct
/// views for destinations.
public struct NavigationViewProvider<V: View, D: NavigationViews>: NavigationViewProviding {
    private let builder: (D) -> V

    /// Creates a provider that uses the given builder to construct views.
    ///
    /// - Parameter builder: A closure that returns a view for each destination.
    public init(@ViewBuilder builder: @escaping (D) -> V) {
        self.builder = builder
    }

    /// Returns a type-erased view for the provided destination.
    public func view(for destination: D) -> AnyView {
        AnyView(builder(destination))
    }
}

/// A view provider that always returns an empty view.
///
/// Useful in tests or when you need a placeholder provider.
public struct MockNavigationViewProvider<D: NavigationViews>: NavigationViewProviding {
    /// Creates a mock provider that always returns `EmptyView`.
    public init() {}
    /// Returns an empty view for any destination.
    public func view(for destination: D) -> AnyView {
        AnyView(EmptyView())
    }
}
