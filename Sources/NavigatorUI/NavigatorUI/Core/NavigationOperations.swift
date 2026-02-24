//
//  NavigationOperations.swift
//  Navigator
//
//  Created by Michael Long on 1/18/25.
//

import SwiftUI

/// A type that can perform imperative navigation actions.
///
/// Conforming types provide operations for navigating to destinations and
/// moving backward through the navigation stack.
public protocol Navigating {
    /// Navigates to a specific NavigationDestination overriding the destination's specified navigation method.
    /// ```swift
    /// Button("Button Present Home Page 55") {
    ///     navigator.navigate(to: HomeDestinations.pageN(55), method: .sheet)
    /// }
    /// ```
    @MainActor func navigate<D: NavigationDestination>(to destination: D, method: NavigationMethod)

    /// Pops an items from the navigation path, or dismiss if we're on the root view.
    /// ```swift
    /// Button("Go Back") {
    ///     navigator.back()
    /// }
    /// ```
    /// This mimics standard SwiftUI dismiss behavior.
    @MainActor @discardableResult func back() -> Bool
}

extension Navigating {
    /// Navigates to a specific ``NavigationDestination`` using the destination's ``NavigationMethod``.
    ///
    /// This may push an item onto the stacks navigation path, or present a sheet or fullscreen cover view.
    /// ```swift
    /// Button("Button Navigate to Home Page 55") {
    ///     navigator.navigate(to: HomeDestinations.pageN(55))
    /// }
    /// ```
    @MainActor
    public func navigate<D: NavigationDestination>(to destination: D) {
        navigate(to: destination, method: destination.method)
    }
}

extension Navigator: Navigating {

    /// Navigates to a specific ``NavigationDestination`` using an explicit method.
    ///
    /// This is the low-level implementation behind the higher-level
    /// ``Navigating/navigate(to:)`` protocol requirement.
    ///
    /// - Parameters:
    ///   - destination: The destination to present.
    ///   - method: The navigation method to use when presenting the destination.
    @MainActor
    public func navigate<D: NavigationDestination>(to destination: D, method: NavigationMethod) {
        switch method {
        case .push:
            push(destination)

        case .send:
            send(destination)

        case .sheet, .managedSheet:
            guard sheet?.id != destination.id else { return }
            log(.navigation(.presenting(destination)))
            sheet = AnyNavigationDestination(wrapped: destination, method: method)

        case .cover, .managedCover:
            guard cover?.id != destination.id else { return }
            log(.navigation(.presenting(destination)))
            #if os(iOS) || os(tvOS) || os(watchOS)
            cover = AnyNavigationDestination(wrapped: destination, method: method)
            #else
            sheet = AnyNavigationDestination(wrapped: destination, method: method)
            #endif
        }
    }

}

extension Navigator {

    /// Pushes a new ``NavigationDestination`` onto the stack's navigation path.
    /// ```swift
    /// Button("Button Push Home Page 55") {
    ///     navigator.push(HomeDestinations.pageN(55))
    /// }
    /// ```
    /// Also supports plain Hashable values for better integration with existing code bases.
    @MainActor
    public func push<D: Hashable>(_ destination: D) {
        log(.navigation(.pushing(destination)))
        if autoDestinationMode {
            if let destination = destination as? AnyNavigationDestination {
                path.append(destination)
            } else if let destination = destination as? any NavigationDestination {
                path.append(AnyNavigationDestination(destination))
            } else {
                push(raw: destination)
            }
        } else {
            push(raw: destination)
        }
    }

    internal func push<D: Hashable>(raw destination: D) {
        if let destination = destination as? any Hashable & Codable {
            path.append(destination) // ensures NavigationPath knows type is Codable
        } else {
            path.append(destination)
        }
    }

    /// Pops to a specific position on stack's navigation path.
    @MainActor
    @discardableResult
    public func pop(to position: Int)  -> Bool {
        log(.navigation(.popping))
        if position <= path.count {
            path.removeLast(path.count - position)
            return true
        }
        return false
    }

    /// Pops the specified number of the items from the end of a stack's navigation path.
    ///
    /// Defaults to one if not specified.
    /// ```swift
    /// Button("Go Back") {
    ///     navigator.pop()
    /// }
    /// ```
    @MainActor
    @discardableResult
    public func pop(last k: Int = 1) -> Bool {
        if path.count >= k {
            log(.navigation(.popping))
            path.removeLast(k)
            return true
        }
        return false
    }

    /// Pops all items from the current navigation path, returning to the root view.
    /// ```swift
    /// Button("Go Root") {
    ///     navigator.popAll()
    /// }
    /// ```
    @MainActor
    @discardableResult
    public func popAll() -> Bool {
        let result = !path.isEmpty
        path = NavigationPath()
        return result
    }

    /// Pops all items from *any* navigation path, returning each to the root view.
    /// ```swift
    /// Button("Pop Any") {
    ///     navigator.popAny()
    /// }
    /// ```
    @MainActor
    @discardableResult
    public func popAny() throws -> Bool {
        guard !isNavigationLocked else {
            log(.warning("Navigator \(id) error navigation locked"))
            throw NavigationError.navigationLocked
        }
        return root.recursivePopAny()
    }

    internal func recursivePopAny() -> Bool {
        var popped = popAll()
        for child in _children.values {
            if let child = child.object {
                popped = child.recursivePopAny() || popped
            }
        }
        return popped
    }

    @MainActor
    @discardableResult
    public func back() -> Bool {
        pop() || dismiss()
    }

}

extension View {

    /// Triggers navigation to a destination whenever the bound value is set.
    ///
    /// Use this when you want to drive navigation from application state.
    /// The bound value is reset to `nil` after navigation completes.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @Environment(\.navigator) private var navigator
    ///     @State private var nextDestination: (any NavigationDestination)?
    ///
    ///     var body: some View {
    ///         List(items) { item in
    ///             Button(item.title) {
    ///                 nextDestination = ItemDestination.details(item)
    ///             }
    ///         }
    ///         .navigate(to: $nextDestination)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter destination: A binding to an optional destination.
    /// - Returns: A view that performs navigation when the binding changes.
    public func navigate(to destination: Binding<(some NavigationDestination)?>) -> some View {
        self.modifier(NavigateToModifier(destination: destination, method: nil))
    }

    /// Triggers navigation to a destination with an explicit method whenever
    /// the bound value is set.
    ///
    /// - Parameters:
    ///   - destination: A binding to an optional destination.
    ///   - method: The navigation method to use when presenting the destination.
    public func navigate(to destination: Binding<(some NavigationDestination)?>, method: NavigationMethod) -> some View {
        self.modifier(NavigateToModifier(destination: destination, method: method))
    }

    /// Triggers navigation to a destination when the bound boolean becomes `true`.
    ///
    /// Use this when you want to keep the destination fixed but control when
    /// navigation occurs via a simple trigger flag.
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showDetails = false
    ///
    ///     var body: some View {
    ///         Button("Show Details") {
    ///             showDetails = true
    ///         }
    ///         .navigate(trigger: $showDetails, destination: DetailsDestination())
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - trigger: A binding that fires navigation when set to `true`.
    ///   - destination: The destination to present.
    public func navigate(trigger: Binding<Bool>, destination: some NavigationDestination) -> some View {
        self.modifier(NavigateTriggerModifier(trigger: trigger, destination: destination, method: nil))
    }

    /// Triggers navigation to a destination with an explicit method when
    /// the bound boolean becomes `true`.
    ///
    /// - Parameters:
    ///   - trigger: A binding that fires navigation when set to `true`.
    ///   - destination: The destination to present.
    ///   - method: The navigation method to use when presenting the destination.
    public func navigate(trigger: Binding<Bool>, destination: some NavigationDestination, method: NavigationMethod) -> some View {
        self.modifier(NavigateTriggerModifier(trigger: trigger, destination: destination, method: method))
    }

}

private struct NavigateToModifier<T: NavigationDestination>: ViewModifier {
    @Environment(\.navigator) internal var navigator: Navigator
    @Binding internal var destination: T?
    internal let method: NavigationMethod?
    func body(content: Content) -> some View {
        content
            .onChange(of: destination) { destination in
                if let destination {
                    navigator.navigate(to: destination, method: method ?? destination.method)
                    self.destination = nil
                }
            }
    }
}

private struct NavigateTriggerModifier<T: NavigationDestination>: ViewModifier {
    @Binding internal var trigger: Bool
    let destination: T
    internal let method: NavigationMethod?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger {
                    navigator.navigate(to: destination, method: method ?? destination.method)
                    self.trigger = false
               }
           }
    }
}
