//
//  NavigationState.swift
//  Navigator
//
//  Created by Michael Long on 1/17/25.
//

import Combine
import SwiftUI

/// Persistent storage for Navigators.
public class NavigationState: ObservableObject, @unchecked Sendable {

    /// Navigation path for the current ManagedNavigationStack
    @Published internal var path: NavigationPath = .init() {
        didSet {
            cleanCheckpoints()
        }
    }

    /// Presentation trigger for .sheet navigation methods.
    @Published internal var sheet: AnyNavigationDestination? = nil

    /// Presentation trigger for .cover navigation methods.
    @Published internal var cover: AnyNavigationDestination? = nil

    /// Dismiss trigger for ManagedNavigationStack or navigationDismissible views.
    @Published internal var triggerDismiss: Bool = false

    /// Persistent id of this navigator.
    internal var id: UUID = .init()

    /// Name of the current ManagedNavigationStack, if any.
    internal var name: String? = nil

   /// Copy of the navigation configuration from the root view.
    internal var configuration: NavigationConfiguration?

    /// Determines whether or not users should see animation steps when deep linking.
    public var executionDelay: TimeInterval {
        configuration?.executionDelay ?? 0.1
    }

    /// Parent navigator, if any.
    internal weak var parent: NavigationState? = nil

    /// Presented children, if any.
    internal var children: [UUID : WeakObject<NavigationState>] = [:] {
        didSet { changed() }
    }

    /// Checkpoints managed by this navigation stack
    internal var checkpoints: [String: NavigationCheckpoint] = [:] {
        didSet { changed() }
    }

    /// True if the current ManagedNavigationStack or navigationDismissible is presented.
    internal var isPresented: Bool = false

    /// Navigation locks, if any
    internal var navigationLocks: Set<UUID> = []

    /// Navigation send publisher
    internal var publisher: PassthroughSubject<NavigationSendValues, Never> = .init()

    /// Allows public initialization of root Navigators.
    internal init(configuration: NavigationConfiguration? = nil) {
        self.name = "root"
        self.configuration = configuration
        log("Navigator root: \(id)")
    }

    /// Internal initializer used by ManagedNavigationStack and navigationDismissible modifiers.
    internal init(name: String?) {
        self.name = name
    }

    /// Sentinel code removes child from parent when Navigator is dismissed or deallocated.
    deinit {
        log("Navigator deinit: \(id)")
        parent?.removeChild(self)
    }

    /// Delayed signal of state change that might occur during the rendering cycle.
    func changed() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    /// Walks up the parent tree and returns the root Navigator.
    internal var root: NavigationState {
        parent?.root ?? self
    }

    /// Adds a child state to parent.
    internal func addChild(_ child: NavigationState, isPresented: Bool) {
        guard !children.keys.contains(child.id) else {
            return
        }
        children[child.id] = WeakObject(object: child)
        child.configuration = configuration
        child.parent = self
        child.publisher = publisher
        child.isPresented = isPresented
        log("Navigator \(id) adding child: \(child.id)")
    }

    /// Removes a child state from a parent.
    internal func removeChild(_ child: NavigationState) {
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

}

extension NavigationState: Hashable, Equatable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.name)
        hasher.combine(self.path.codable.debugDescription)
        hasher.combine(self.checkpoints)
        hasher.combine(self.sheet)
        hasher.combine(self.cover)
    }

    public static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        lhs.id == rhs.id
    }

}

extension NavigationState {

    /// Errors that Navigator can throw
    public enum NavigationError: Error {
        case navigationLocked
    }

    /// Allows weak storage of reference types in arrays, dictionaries, and other collection types.
    internal struct WeakObject<T: AnyObject> {
        weak var object: T?
    }

}
