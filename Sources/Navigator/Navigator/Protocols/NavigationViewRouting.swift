//
//  NavigationViewRouting.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI

public protocol ExternalNavigationRoutes: Hashable {}

public protocol ExternalNavigationRouting<R> {
    associatedtype R: ExternalNavigationRoutes
    func canRoute(to destination: R) -> Bool
    func route(to destination: R)
}

extension ExternalNavigationRouting {
    public func canRoute(to destination: R) -> Bool {
        true
    }
}

public struct ExternalNavigationRouter<R: ExternalNavigationRoutes>: ExternalNavigationRouting {
    private let router: (R) -> Void
    public init(router: @escaping (R) -> Void) {
        self.router = router
    }
    public func route(to destination: R) {
        router(destination)
    }
}

public struct MockExternalNavigationRouter<R: ExternalNavigationRoutes>: ExternalNavigationRouting {
    public init() {}
    public func route(to destination: R) {}
}

