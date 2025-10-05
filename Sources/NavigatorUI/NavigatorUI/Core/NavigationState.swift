//
//  NavigationState.swift
//  Navigator
//
//  Created by Michael Long on 1/17/25.
//

import Combine
import SwiftUI

/// Persistent storage for Navigators.
nonisolated public class NavigationState: ObservableObject, @unchecked Sendable {

    public enum Owner: Int {
        case application
        case root
        case stack
        case presenter
    }

    // MARK: Internal properties

    /// Navigation path for the current ManagedNavigationStack
    internal var path: NavigationPath = .init() {
        willSet {
            objectWillChange.send()
        }
        didSet {
            cleanCheckpoints()
            pathChangedCounter += 1
        }
    }

    /// Presentation trigger for .sheet navigation methods.
    internal var sheet: AnyNavigationDestination? = nil {
        willSet { objectWillChange.send() }
    }

    /// Presentation trigger for .cover navigation methods.
    internal var cover: AnyNavigationDestination? = nil{
        willSet { objectWillChange.send() }
    }

    /// Checkpoints managed by this navigation stack
    internal var checkpoints: [String: AnyNavigationCheckpoint] = [:] {
        willSet { objectWillChange.send() }
    }

    /// Navigation locks, if any
    internal var navigationLocks: Set<UUID> = [] {
        willSet { objectWillChange.send() }
    }

    /// Persistent id of this navigator.
    internal var id: UUID = .init()

    /// Name of the current ManagedNavigationStack, if any.
    internal var name: String? = nil

    /// Owner of this particular state object.
    internal var owner: Owner = .root

   /// Copy of the navigation configuration from the root view.
    internal var configuration: NavigationConfiguration?

    /// Determines whether or not users should see animation steps when deep linking.
    public var executionDelay: TimeInterval {
        configuration?.executionDelay ?? 0.6
    }

    /// Update counter for navigation path.
    internal var pathChangedCounter: Int = 0

    /// Parent navigator, if any.
    internal weak var parent: NavigationState? = nil

    /// Presented children, if any.
    internal var children: [UUID : WeakObject<NavigationState>] = [:]

    /// True if the current ManagedNavigationStack or navigationDismissible is presented.
    internal var isPresented: Bool {
        dismissAction != nil
    }

    /// Dismissible function for this particular state object.
    internal var dismissAction: DismissAction?

    /// Navigation send publisher
    internal var publisher: PassthroughSubject<NavigationSendValues, Never> = .init()

    /// Registered navigation destinations
    internal var navigationDestinations: Set<ObjectIdentifier> = []

    /// Registered view providers
    internal var navigationProviders: [ObjectIdentifier : Any] = [:]

    /// Use AnyNavigationDestination for all pushed NavigationDestination values, avoiding need to register destinations
    internal var autoDestinationMode: Bool {
        autoDestinationModeOverride ?? configuration?.autoDestinationMode ?? false
    }

    /// set by NavigationAutoDestinationModeModifier
    internal var autoDestinationModeOverride: Bool?

    /// Storage for .navigationMap modifier
    internal var navigationMap: ((any NavigationDestination) -> any NavigationDestination)?
    internal var navigationMapInherits: Bool = false

    /// Storage for .navigationModifier
    internal var navigationModifier: ((any NavigationDestination) -> any View)?
    internal var navigationModifierInherits: Bool = false

    /// Storage for .presentationModifier
    internal var presentationModifier: ((any NavigationDestination) -> any View)?
    internal var presentationModifierInherits: Bool = false

    // MARK: Lifecycle

    /// Allows public initialization of root Navigators.
    internal init(configuration: NavigationConfiguration? = nil) {
        self.name = "root"
        self.configuration = configuration
        log(.lifecycle(.configured))
    }

    /// Internal initializer used by ManagedNavigationStack and navigationDismissible modifiers.
    internal init(owner: Owner, name: String?) {
        self.owner = owner
        self.name = name
    }

    /// Sentinel code removes child from parent when Navigator is dismissed or deallocated.
    deinit {
        log(.lifecycle(.deinit))
        parent?.removeChild(self)
    }

    // MARK: Navigation tree support

    /// Walks up the parent tree and returns the root Navigator.
    internal var root: NavigationState {
        parent?.root ?? self
    }

    /// Adds a child state to parent.
    internal func addChild(_ child: NavigationState, dismissible: DismissAction?) {
        // always update dismissible closure
        child.dismissAction = dismissible
        // exit if already addd
        guard !children.keys.contains(child.id) else {
            return
        }
        children[child.id] = WeakObject(object: child)
        child.configuration = configuration
        child.parent = self
        child.publisher = publisher
        child.navigationMap = navigationMapInherits ? navigationMap : nil
        child.navigationMapInherits = navigationMapInherits
        child.navigationModifier = navigationModifierInherits ? navigationModifier : nil
        child.navigationModifierInherits = navigationModifierInherits
        child.presentationModifier = presentationModifierInherits ? presentationModifier : nil
        child.presentationModifierInherits = presentationModifierInherits
        log(.lifecycle(.adding(child.id)))
    }

    /// Removes a child state from a parent.
    internal func removeChild(_ child: NavigationState) {
        log(.lifecycle(.removing(child.id)))
        children.removeValue(forKey: child.id)
        child.dismissAction = nil
    }

    /// Renames state for wrapped navigation stacks.
    internal func setting(_ name: String?) -> NavigationState {
        self.name = name
        return self
    }

}

extension NavigationState: Hashable, Equatable {

    // MARK: Hashable, Equatable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.name)
        hasher.combine(self.pathChangedCounter)
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
