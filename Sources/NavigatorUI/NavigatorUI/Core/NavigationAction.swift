//
//  NavigationAction.swift
//  Navigator
//
//  Created by Michael Long on 1/10/25.
//

import SwiftUI

extension Navigator {

    /// Performs one or more navigation actions as a single send operation.
    ///
    /// This is a convenience wrapper around ``Navigator/send(values:)`` for
    /// ``NavigationAction`` values.
    ///
    /// ```swift
    /// navigator.perform(
    ///     .dismissAny,
    ///     .popAny
    /// )
    /// ```
    ///
    /// - Parameter actions: The actions to enqueue for execution.
    @MainActor
    public func perform(_ actions: NavigationAction...) {
        send(values: actions)
    }

    /// Performs a sequence of navigation actions provided as an array.
    ///
    /// - Parameter actions: The actions to enqueue for execution.
    @MainActor
    public func perform(actions: [NavigationAction]) {
        send(values: actions)
    }

}

/// A named, hashable unit of navigation work that can be enqueued and
/// executed by a ``Navigator``.
///
/// Actions are usually created via one of the static factory helpers
/// (such as ``NavigationAction/dismissAny``) and sent using
/// ``Navigator/send(values:)`` or ``Navigator/perform(_:)``.
nonisolated public struct NavigationAction: Hashable {

    /// A human-readable name used for logging, equality, and hashing.
    public let name: String

    private let action: (Navigator) -> NavigationReceiveResumeType

    /// Creates a navigation action with an optional name and the work to perform.
    ///
    /// - Parameters:
    ///   - name: An optional name used for logging and identity. Defaults to the
    ///     calling function name.
    ///   - action: The closure that performs the navigation work and returns
    ///     a ``NavigationReceiveResumeType`` to control any remaining values.
    public init(_ name: String = #function, action: @escaping (Navigator) -> NavigationReceiveResumeType) {
        self.name = name
        self.action = action
    }

    /// Executes the underlying action with the given navigator.
    ///
    /// - Parameter navigator: The navigator that should perform the work.
    /// - Returns: A ``NavigationReceiveResumeType`` indicating how to handle
    ///   any remaining values in the send queue.
    public func callAsFunction(_ navigator: Navigator) -> NavigationReceiveResumeType {
        action(navigator)
    }

    /// Hashes the action based on its name.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    /// Two navigation actions are equal when their names match.
    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        lhs.name == rhs.name
    }

}

extension NavigationAction {

    /// Action allows user to construct actions on the fly
    @MainActor public static func action(handler: @escaping (Navigator) -> NavigationReceiveResumeType) -> NavigationAction {
        .init(action: handler)
    }

    /// Dismisses all presented views.
    ///
    /// If navigation dismissal is locked, this action will cancel and no further actions in this sequence will be executed.
    @MainActor public static var dismissAny: NavigationAction {
        .init {
            do {
                return try $0.dismissAny() ? .auto : .immediately
            } catch {
                return .cancel
            }
        }
    }

    /// Empty action, usually used as a placeholder for a definition to be provided later.
    @MainActor public static var empty: NavigationAction {
        .init { _ in .immediately }
    }

    /// Cancels if navigation is locked.
    @MainActor public static var locked: NavigationAction {
        .init { navigator in
            navigator.isNavigationLocked ? .cancel : .immediately
        }
    }

    /// Empty action, usually used as a placeholder for a definition to be provided later.
    @MainActor public static var pause: NavigationAction {
        .init { _ in .pause }
    }

    /// Finds named navigator and pops it back to the root.
    @MainActor public static func popAll(in name: String) -> NavigationAction {
        .init { navigator in
            if let found = navigator.named(name) {
                return found.popAll() ? .auto : .immediately
            }
            return .cancel
        }
    }

    /// Dismisses any presented views and resets all paths back to zero.
    ///
    ///  Inserts value into the queue for next send in order to correctly handle that values resume type.
    @MainActor public static var popAny: NavigationAction {
        .init {
            do {
                return try $0.popAny() ? .auto : .immediately
            } catch {
                return .cancel
            }
        }
    }

    /// Dismisses any presented views and resets all paths back to zero.
    ///
    ///  Inserts value into the queue for next send in order to correctly handle that values resume type.
    @MainActor public static var reset: NavigationAction {
        .init { _ in .inserting([NavigationAction.dismissAny, NavigationAction.popAny]) }
    }

    /// Sends value via navigation send.
    ///
    ///  Inserts value into the queue for next send in order to correctly handle that values resume type.
    @MainActor public static func send(_ value: any Hashable) -> NavigationAction {
        .init { _ in .inserting([value]) }
    }

    /// Finds named navigator and passes it to closure for imperative action.
    ///
    /// If not found the closure will not be called and this action will cancel.
    @MainActor public static func with(navigator name: String, perform: @escaping (Navigator) -> Void) -> NavigationAction {
        .init { navigator in
            if let found = navigator.named(name) {
                perform(found)
                return .auto
            }
            return .cancel
        }
    }

}
