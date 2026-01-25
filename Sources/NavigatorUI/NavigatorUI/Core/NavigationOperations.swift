//
//  NavigationOperations.swift
//  Navigator
//
//  Created by Michael Long on 1/18/25.
//

import SwiftUI

extension Navigator {

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

    /// Navigates to a specific NavigationDestination overriding the destination's specified navigation method.
    /// ```swift
    /// Button("Button Present Home Page 55") {
    ///     navigator.navigate(to: HomeDestinations.pageN(55), method: .sheet)
    /// }
    /// ```
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

    /// Pops an items from the navigation path, or dismiss if we're on the root view.
    /// ```swift
    /// Button("Go Back") {
    ///     navigator.back()
    /// }
    /// ```
    /// This mimics standard SwiftUI dismiss behavior.
    @MainActor
    @discardableResult
    public func back() -> Bool {
        pop() || dismiss()
    }

    /// Indicates whether or not the navigation path is empty.
    public var isEmpty: Bool {
        path.isEmpty
    }

    /// Number of items in the navigation path.
    public var count: Int {
        path.count
    }

}

extension View {

    public func navigate(to destination: Binding<(some NavigationDestination)?>) -> some View {
        self.modifier(NavigateToModifier(destination: destination, method: nil))
    }

    public func navigate(to destination: Binding<(some NavigationDestination)?>, method: NavigationMethod) -> some View {
        self.modifier(NavigateToModifier(destination: destination, method: method))
    }

    public func navigate(trigger: Binding<Bool>, destination: some NavigationDestination) -> some View {
        self.modifier(NavigateTriggerModifier(trigger: trigger, destination: destination, method: nil))
    }

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
