//
//  NavigationModifiers.swift
//  NavigatorUI
//
//  Created by Michael Long on 9/14/25.
//

import SwiftUI

extension View {

    /// NavigationMap lets you map destination values before they're pushed or presented.
    /// ```swift
    /// struct HomeRootView: View {
    ///     @StateObject var viewModel: HomeRootViewModel
    ///     var body: some View {
    ///         ManagedNavigationStack {
    ///             HomeContentView()
    ///                 .navigationMap { destination in
    ///                     switch destination {
    ///                     case SharedDestinations.homePageDetails:
    ///                         HomeDestinations.pageN(99)
    ///                     default:
    ///                         destination
    ///                     }
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    /// Here when a view wants to push or present `SharedDestinations.homePageDetails`, `HomeDestinations.pageN(99)` will be pushed or
    /// presented instead. This is handy in multi-module environments.
    ///
    /// The inherited flags indicates whether or not child ManagedNavigationStacks should inherit this behavior as well.
    ///
    /// Note that mapping only works with views pushed or presented by Navigator.
    public func navigationMap(inherits: Bool = true,_ modifier: @escaping (any NavigationDestination) -> any NavigationDestination) -> some View {
        self.modifier(NavigationExecutionModifier { navigator in
            navigator.state.navigationMap = modifier
            navigator.state.navigationMapInherits = inherits
        })
    }

    /// The `navigationModifier` lets you apply a common set of modifiers to any pushed views.
    /// ```swift
    /// struct HomeRootView: View {
    ///     @StateObject var viewModel: HomeRootViewModel
    ///     var body: some View {
    ///         ManagedNavigationStack {
    ///             HomeContentView()
    ///                 .navigationModifier { destination in
    ///                     destination()
    ///                          .toolbarBackground(.hidden, for: .navigationBar)
    ///                          .toolbarTitleDisplayMode(.inline)
    ///                          .toolbar(.hidden, for: .tabBar)
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    /// The inherited flags indicates whether or not child ManagedNavigationStacks should inherit this behavior as well.
    ///
    /// Note that these modifications only apply to views pushed by Navigator.
    public func navigationModifier(
        inherits: Bool = false,
        @ViewBuilder _ modifier: @escaping (any NavigationDestination) -> any View
    ) -> some View {
        self.modifier(NavigationExecutionModifier { navigator in
            navigator.state.navigationModifier = modifier
            navigator.state.navigationModifierInherits = inherits
        })
    }

    /// The `presentationModifier` lets you apply a common set of modifiers to any presented views.
    /// ```swift
    /// struct HomeRootView: View {
    ///     @StateObject var viewModel: HomeRootViewModel
    ///     var body: some View {
    ///         ManagedNavigationStack {
    ///             HomeContentView()
    ///                 .navigationModifier(inherits: true) { destination in
    ///                     destination()
    ///                          .tint(.white)
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    /// The inherited flags indicates whether or not child ManagedNavigationStacks should inherit this behavior as well.
    ///
    /// Note that these modifications only apply to views presented by Navigator.
    public func presentationModifier(
        inherits: Bool = false,
        @ViewBuilder _ modifier: @escaping (any NavigationDestination) -> any View
    ) -> some View {
        self.modifier(NavigationExecutionModifier { navigator in
            navigator.state.presentationModifier = modifier
            navigator.state.presentationModifierInherits = inherits
        })
    }

}

extension Navigator {
    /// Retrieves mapped values for external navigation modes.
    ///
    /// See `navigationModifier` for examples.
    @MainActor
    public func mappedNavigationView(for destination: any NavigationDestination) -> AnyView {
        state.mappedNavigationView(for: destination)
    }

    /// Retrieves mapped values for external presentation modes.
    ///
    /// See `presentationModifier` for examples.
    @MainActor
    public func mappedPresentationView(for destination: any NavigationDestination) -> AnyView {
        state.mappedPresentationView(for: destination)
    }
}

extension NavigationState {
    @MainActor
    internal func mappedNavigationView(for destination: any NavigationDestination) -> AnyView {
        let mapped = navigationMap?(destination) ?? destination
        if let modifier = navigationModifier {
            return AnyView(modifier(mapped))
        } else {
            return mapped.asAnyView()
        }
    }

    @MainActor
    internal func mappedPresentationView(for destination: any NavigationDestination) -> AnyView {
        let mapped = navigationMap?(destination) ?? destination
        if let modifier = presentationModifier {
            return AnyView(modifier(mapped))
        } else {
            return mapped.asAnyView()
        }
    }
}

internal struct NavigationExecutionModifier: ViewModifier {
    @Environment(\.navigator) var navigator
    let block: (Navigator) -> Void
    func body(content: Content) -> some View {
        content
            .onAppear {
                block(navigator)
            }
    }
}
