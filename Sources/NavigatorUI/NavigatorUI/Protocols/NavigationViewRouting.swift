//
//  NavigationViewRouting.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI

/// A type that can route strongly-typed navigation routes using a `Navigator`.
///
/// Conforming types translate high-level route values into concrete navigation
/// actions, such as pushing destinations, presenting sheets, or performing
/// side effects.
public protocol NavigationRouting<R> {
    associatedtype R: NavigationRoutes

    /// Routes to the provided destination.
    ///
    /// Implementations typically use the `Navigator` to perform navigation
    /// or other side effects associated with the route.
    ///
    /// - Parameter destination: The route value to handle.
    /// - Throws: Any error encountered while performing the route.
    @MainActor func route(to destination: R) throws
}

/// A concrete router that uses a closure to perform routing for a given
/// `NavigationRoutes` type.
public struct NavigationRouter<R: NavigationRoutes>: NavigationRouting {
    private let navigator: Navigator
    private let router: (R) throws -> Void

    /// Creates a router that uses the provided closure to handle routes.
    ///
    /// - Parameters:
    ///   - navigator: The navigator used to perform any navigation actions.
    ///   - router: A closure that receives each route value to handle.
    public init(_ navigator: Navigator, router: @escaping (R) -> Void) {
        self.navigator = navigator
        self.router = router
    }

    /// Routes to the provided destination by invoking the configured closure.
    ///
    /// - Parameter destination: The route value to handle.
    /// - Throws: Any error thrown by the router closure.
    @MainActor public func route(to destination: R) throws {
        try router(destination)
    }
}

/// A router implementation that ignores all routes.
///
/// Useful in tests or previews where routing should be disabled.
public struct MockNavigationRouter<R: NavigationRoutes>: NavigationRouting {
    /// Creates a mock router that performs no actions.
    public init() {}
    /// Discards the provided route without performing any work.
    @MainActor public func route(to destination: R) throws {}
}
