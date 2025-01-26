//
//  NavigationViewRouting.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI

public protocol NavigationRoutes: Hashable {}

public protocol NavigationRouting<R> {
    associatedtype R: NavigationRoutes
    @MainActor func route(to destination: R)
}

public struct NavigationRouter<R: NavigationRoutes>: NavigationRouting {
    private let router: (R) -> Void
    public init(router: @escaping (R) -> Void) {
        self.router = router
    }
    @MainActor public func route(to destination: R) {
        router(destination)
    }
}

public struct MockNavigationRouter<R: NavigationRoutes>: NavigationRouting {
    public init() {}
    @MainActor public func route(to destination: R) {}
}
