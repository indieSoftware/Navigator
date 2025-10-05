//
//  ExternalNavigationDestination.swift
//  Navigator
//
//  Created by Michael Long on 1/14/25.
//

import SwiftUI

/// Defines a set of view destinations whose views will be provided elsewhere by the `onNavigationProvidedView` modifier.
/// ```swift
/// nonisolated public enum SharedDestinations: NavigationProvidedDestination {
///     case newOrder
///     case orderDetails(Order)
///     case produceDetails(Product)
/// }
/// ```
/// This enables modular applications to create NavigationDestinations on external dependencies
/// that might not be known by that particular module and known only to the application.
public protocol NavigationProvidedDestination: NavigationDestination {}

extension NavigationProvidedDestination {
    // default implementation of the view body
    public var body: some View {
        NavigationProvidedView(for: self)
    }
}

extension Navigator {
    /// Implements the internal lookup mechanism for `NavigationProvidedDestination`.
    public func navigationProvidedView<D: NavigationDestination>(for destination: D) -> (any View)? {
        root.state.view(for: destination)
    }
}

extension View {
    /// Defines the set of views required by `NavigationProvidedDestination`.
    /// ```swift
    /// import Shared
    /// import Orders
    /// import Products
    /// import NavigatorUI
    /// import SwiftUI
    ///
    /// struct ContentView: View {
    ///     let navigator: Navigator = .init(configuration: .init())
    ///     var body: some View {
    ///         RootTabView()
    ///             // provide Shared views
    ///             .onNavigationProvidedView(SharedDestinations.self) {
    ///                 switch $0 {
    ///                 case .newOrder:
    ///                     NewOrderView()
    ///                 case .orderDetails(let order:
    ///                     OrderDetailsView(order)
    ///                 case .produceDetails(let product):
    ///                     ProductDestinations.details(product)
    ///                 }
    ///             }
    ///             // setup managed navigation root
    ///             .navigationRoot(navigator)
    ///     }
    /// }
    /// ```
    /// This enables modular applications to create NavigationDestinations on external dependencies
    /// that might not be known by that particular module and known only to the application.
    public func onNavigationProvidedView<D: NavigationDestination>(_ type: D.Type = D.self, @ViewBuilder _ provider: @escaping (D) -> any View) -> some View {
        self.modifier(NavigationProvidedViewModifier(provider))
    }
}

internal struct NavigationProvidedViewModifier<D: NavigationDestination>: ViewModifier {
    @Environment(\.navigator) private var navigator
    @StateObject private var sentinel: NavigationViewProvidingSentinel<D>

    init(_ views: @escaping (D) -> any View) {
        self._sentinel = .init(wrappedValue: .init(views))
    }

    func body(content: Content) -> some View {
        content
            .task(id: 1) {
                navigator.register(provider: sentinel)
            }
    }
}

extension Navigator {
    internal func register<D: NavigationDestination>(provider: NavigationViewProvidingSentinel<D>) {
        root.state.register(provider)
    }
}

internal class NavigationViewProvidingSentinel<D: NavigationDestination>: ObservableObject {

    internal let views: (D) -> any View

    private weak var state: NavigationState?

    init(_ views: @escaping (D) -> any View) {
        self.views = views
    }

    deinit {
        state?.unregister(type: D.self)
    }

    func register(state: NavigationState) {
        self.state = state
    }
}

extension NavigationState {
    internal func register<D: NavigationDestination>(_ provider: NavigationViewProvidingSentinel<D>) {
        navigationProviders[ObjectIdentifier(D.self)] = provider
    }

    internal func unregister(type: Any.Type) {
        navigationProviders.removeValue(forKey: ObjectIdentifier(type))
    }

    internal func view<D: NavigationDestination>(for destination: D) -> (any View)? {
        if let provider = navigationProviders[ObjectIdentifier(D.self)] as? NavigationViewProvidingSentinel<D> {
            log(.providing(.destination(destination)))
            return provider.views(destination)
        }
        log(.warning("missing onNavigationProvidedView for \(type(of: destination))"))
        return nil
    }
}
