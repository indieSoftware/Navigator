//
//  NavigationViewProviding.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI
import Navigator

public protocol ExternalNavigationViews: Hashable {}

public protocol ExternalNavigationViewProviding<D> {
    associatedtype D: ExternalNavigationViews
    func view(for destination: D) -> AnyView
}

public struct ExternalNavigationViewProvider<V: View, D: ExternalNavigationViews>: ExternalNavigationViewProviding {
    private let builder: (D) -> V
    public init(@ViewBuilder builder: @escaping (D) -> V) {
        self.builder = builder
    }
    public func view(for destination: D) -> AnyView {
        AnyView(builder(destination))
    }
}

public struct MockExternalNavigationViewProvider<D: ExternalNavigationViews>: ExternalNavigationViewProviding {
    public init() {}
    public func view(for destination: D) -> AnyView {
        AnyView(EmptyView())
    }
}

