//
//  NavigationActionProviding.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/25/25.
//


import Navigator
import SwiftUI

public protocol NavigationActionProviding<Route> {
    associatedtype Route: Hashable
    @MainActor func actions(for route: Route) -> [NavigationAction]
}

public struct NavigationActionProvider<Route: Hashable>: NavigationActionProviding {
    private let router: (Route) -> [NavigationAction]
    public init(router: @escaping (Route) -> [NavigationAction]) {
        self.router = router
    }
    @MainActor public func actions(for route: Route) -> [NavigationAction] {
        router(route)
    }
}

public struct EmptyNavigationActionProvider<Route: Hashable>: NavigationActionProviding {
    @MainActor public func actions(for route: Route) -> [NavigationAction] {
        []
    }
}
