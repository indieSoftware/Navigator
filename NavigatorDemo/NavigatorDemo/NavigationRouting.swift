//
//  NavigationRouting.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI
import Navigator

public protocol ExternalNavigationRoutes: Hashable {}

public protocol ExternalNavigationRouting<R> {
    associatedtype R: ExternalNavigationRoutes
    func route(to destination: R)
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

