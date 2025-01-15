//
//  Navigator.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import Combine
import SwiftUI

/// Every ManagedNavigationStack has a Navigator to manage it.
///
/// Navigators enable imperative, programatic control of their associated navigation stacks,
/// ```swift
/// Button("Button Navigate to Home Page 55") {
///     navigator.navigate(to: HomeDestinations.pageN(55))
/// }
/// ```
/// Navigators work with other navigators in the navigation tree to enable global operations like
/// sending navigation values or returning to a parent's checkpoint.
/// ```swift
/// Button("Cancel") {
///     navigator.returnToCheckpoint(.home)
/// }
/// ```
/// Navigators are accessible from the environment. Just access them from within any view contained by
/// a ``ManagedNavigationStack``.
/// ```swift
/// @Environmnt(\.navigator) var navigator
/// ```
public class Navigator: ObservableObject, @unchecked Sendable {

    @Published internal var path: NavigationPath = .init() {
        didSet {
            cleanCheckpoints()
        }
    }

    @Published internal var sheet: AnyNavigationDestination? = nil
    @Published internal var cover: AnyNavigationDestination? = nil
    @Published internal var triggerDismiss: Bool = false

    /// True if the current ManagedNavigationStack or navigationDismissible is presented.
    public internal(set) var isPresented: Bool

    internal let configuration: NavigationConfiguration?

    internal weak var parent: Navigator?
    internal var children: [UUID : WeakObject<Navigator>] = [:]

    internal var id: UUID = .init()
    internal var checkpoints: [String: NavigationCheckpoint] = [:]

    internal let publisher: PassthroughSubject<NavigationSendValues, Never>

    /// Allows public initialization of root Navigators.
    public init(configuration: NavigationConfiguration? = nil) {
        self.configuration = configuration
        self.parent = nil
        self.publisher = .init()
        self.isPresented = false
        log("Navigator root: \(id)")
    }

    /// Internal initializer used by ManagedNavigationStack and navigationDismissible modifiers.
    internal init(parent: Navigator, isPresented: Bool) {
        self.configuration = parent.configuration
        self.parent = parent
        self.publisher = parent.publisher
        self.isPresented = isPresented
        parent.addChild(self)
        log("Navigator init: \(id), parent: \(parent.id)")
     }

    /// Sentinel code removes child from parent when Navigator is dismissed or deallocated.
    deinit {
        log("Navigator deinit: \(id)")
        parent?.removeChild(self)
    }

    /// Walks up the parent tree and returns the root Navigator.
    internal var root: Navigator {
        parent?.root ?? self
    }

    /// Adds a child Navigator to a parent Navigator.
    internal func addChild(_ child: Navigator) {
        children[child.id] = WeakObject(object: child)
    }

    /// Removes a child Navigator from a parent Navigator.
    internal func removeChild(_ child: Navigator) {
        children.removeValue(forKey: child.id)
    }

    /// Internal logging function.
    internal func log(type: NavigationConfiguration.Verbosity = .info, _ message: @autoclosure () -> String) {
        #if DEBUG
        guard let configuration, type.rawValue >= configuration.verbosity.rawValue else {
            return
        }
        root.configuration?.logger?(message())
        #endif
    }

    /// Allows weak storage of reference types in arrays, dictionaries, and other collection types.
    internal struct WeakObject<T: AnyObject> {
        weak var object: T?
    }

}

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
    ///
    /// This may push an item onto the stacks navigation path, or present a sheet or fullscreen cover view.
    @MainActor
    public func navigate<D: NavigationDestination>(to destination: D, method: NavigationMethod) {
        log("Navigator navigating to: \(destination), via: \(method)")
        switch method {
        case .push:
            push(destination)

        case .send:
            send(destination)

        case .sheet:
            guard sheet?.id != destination.id else { return }
            sheet = AnyNavigationDestination(wrapped: destination)

        case .cover:
            guard cover?.id != destination.id else { return }
            #if os(iOS)
            cover = AnyNavigationDestination(wrapped: destination)
            #else
            sheet = AnyNavigationDestination(wrapped: destination)
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
    @MainActor
    public func push(_ destination: any NavigationDestination) {
        if let destination = destination as? any Hashable & Codable {
            path.append(destination) // ensures NavigationPath knows type is Codable
        } else {
            path.append(destination)
        }
    }

    /// Pops to a specific position on stack's navigation path.
    @MainActor
    public func pop(to position: Int) {
        if position <= path.count {
            path.removeLast(path.count - position)
        }
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
    public func pop(last k: Int = 1) {
        if path.count >= k {
            path.removeLast(k)
        }
    }

    /// Pops all items from the navigation path, returning to the root view.
    /// ```swift
    /// Button("Go Back") {
    ///     navigator.popAll()
    /// }
    /// ```
    @MainActor
    public func popAll() {
        path.removeLast(path.count)
    }

    /// Indicates whether or not the navigation path is empty.
    public nonisolated var isEmpty: Bool {
        path.isEmpty
    }

    /// Number of items in the navigation path.
    public nonisolated var count: Int {
        path.count
    }

}

extension EnvironmentValues {
    /// Reference to the Navigator managing the current ManagedNavigationStack.
    @Entry public var navigator: Navigator = Navigator.defaultNavigator
}

extension Navigator {
    // Exists since EnvironmentValues loves to recreate default values
    internal static let defaultNavigator: Navigator = Navigator()
}
