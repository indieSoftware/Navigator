//
//  NavigationRoutes.swift
//  Navigator
//
//  Created by Michael Long on 2/3/25.
//

import SwiftUI

/// A marker protocol for values that represent high-level navigation routes.
///
/// Routes are hashable values that can be broadcast through the navigation
/// system and handled by types that conform to ``NavigationRouteHandling``.
nonisolated public protocol NavigationRoutes: Hashable {}

extension Navigator {

    /// Sends a strongly-typed route through the navigation system.
    ///
    /// This is a convenience wrapper around ``Navigator/send(values:)``
    /// for values that conform to ``NavigationRoutes``.
    ///
    /// ```swift
    /// enum AppRoute: NavigationRoutes {
    ///     case home
    ///     case details(id: UUID)
    /// }
    ///
    /// navigator.perform(route: AppRoute.details(id: id))
    /// ```
    ///
    /// - Parameter route: The route value to broadcast.
    @MainActor
    public func perform<R: NavigationRoutes>(route: R) {
        send(route)
    }
}

/// A type that can handle navigation routes of a specific type.
///
/// Conforming types receive route values and a `Navigator`, and are
/// responsible for performing the appropriate navigation or side effects.
public protocol NavigationRouteHandling {
    associatedtype Route: NavigationRoutes

    /// Handles the provided route using the given navigator.
    ///
    /// - Parameters:
    ///   - route: The route value to handle.
    ///   - navigator: The navigator used to perform any navigation actions.
    @MainActor
    func route(to route: Route, with navigator: Navigator)
}

extension View {

    /// Registers a handler for navigation routes emitted by an ancestor `Navigator`.
    ///
    /// Apply this modifier to a view that should respond to navigation routes
    /// produced by the nearest `Navigator` in the environment. The provided
    /// `router` receives each route and is responsible for performing the
    /// appropriate navigation or side effects.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     enum Route: NavigationRoutes {
    ///         case details(id: UUID)
    ///     }
    ///
    ///     struct Router: NavigationRouteHandling {
    ///         typealias Route = ContentView.Route
    ///
    ///         @MainActor
    ///         func route(to route: Route, with navigator: Navigator) {
    ///             switch route {
    ///             case .details(let id):
    ///                 navigator.navigate(to: DetailsDestination(id: id))
    ///             }
    ///         }
    ///     }
    ///
    ///     var body: some View {
    ///         ItemsList()
    ///             .onNavigationRoute(Router())
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter router: An object that conforms to ``NavigationRouteHandling``
    ///   and knows how to handle the routes produced by the `Navigator`.
    /// - Returns: A view that installs the route handler into the navigation
    ///   environment while it is in the view hierarchy.
    public func onNavigationRoute<R: NavigationRouteHandling>(_ router: R) -> some View {
        self.onNavigationReceive { (route: R.Route, navigator) in
            router.route(to: route, with: navigator)
            return .auto
        }
    }
}
