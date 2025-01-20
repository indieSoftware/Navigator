//
//  NavigationDismiss.swift
//  Navigator
//
//  Created by Michael Long on 11/27/24.
//

import SwiftUI

extension Navigator {

    /// Dismisses the currently presented ManagedNavigationStack.
    @MainActor
    @discardableResult
    public func dismiss() -> Bool {
        state.dismiss()
    }

    /// Dismisses presented sheet or fullScreenCover views presented by this Navigator.
    @MainActor
    public func dismissPresentedViews() {
        state.sheet = nil
        state.cover = nil
    }

    /// Returns to the root Navigator and dismisses *any* presented ManagedNavigationStack.
    @MainActor
    @discardableResult
    public func dismissAll() throws -> Bool {
        try state.dismissAll()
    }

    /// Dismisses *any* ManagedNavigationStack or navigationDismissible presented by any child of this Navigator.
    @MainActor
    @discardableResult
    public func dismissAllChildren() -> Bool {
        state.dismissAllChildren()
    }

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isPresenting: Bool {
        state.isPresenting
    }

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presented.
    public nonisolated var isPresented: Bool {
        state.isPresented
    }

}

extension View {

    /// Dismisses the current ManagedNavigationStack or navigationDismissible if presented.
    ///
    /// Trigger value will be reset to false on dismissal.
    public func navigationDismiss(trigger: Binding<Bool>) -> some View {
        self.modifier(NavigationDismissModifier(trigger: trigger))
    }

    /// Returns to the root Navigator and dismisses *any* presented ManagedNavigationStack.
    ///
    /// Trigger value will be reset to false on dismissal.
    public func navigationDismissAll(trigger: Binding<Bool>) -> some View {
        self.modifier(NavigationDismissModifierAll(trigger: trigger))
    }

    /// Apply to a presented view on which you want to prevent global dismissal.
    public func navigationLocked() -> some View {
        self.modifier(NavigationLockedModifier())
    }

}

extension NavigationState {

    internal func dismiss() -> Bool {
        if isPresented {
            triggerDismiss = true
            log("Navigator dimsissing: \(id)")
            return true
        }
        return false
    }

    /// Returns to the root Navigator and dismisses *any* presented ManagedNavigationStack.
    internal func dismissAll() throws -> Bool {
        guard !isNavigationLocked else {
            log(type: .warning, "Navigator \(id) error navigation locked")
            throw NavigationError.navigationLocked
        }
        return root.dismissAllChildren()
    }

    internal func dismissAllChildren() -> Bool {
        for child in children.values {
            if let childNavigator = child.object {
                if #available (iOS 18.0, *) {
                    if childNavigator.dismiss() || childNavigator.dismissAllChildren() {
                        return true
                    }
                } else {
                    var dismissed: Bool
                    // both functions need to execute, || would short-circuit
                    dismissed = childNavigator.dismissAllChildren()
                    dismissed = childNavigator.dismiss() || dismissed
                    if dismissed {
                        return true
                    }
                }
            }
        }
        return false
    }

    internal nonisolated var isPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false }) != nil
    }

    internal var isNavigationLocked: Bool {
        !root.navigationLocks.isEmpty
    }

    internal func addNavigationLock(id: UUID) {
        root.navigationLocks.insert(id)
    }

    internal func removeNavigationLock(id: UUID) {
        root.navigationLocks.remove(id)
    }

}

private struct NavigationDismissModifier: ViewModifier {
    @Binding internal var trigger: Bool
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger {
                    self.trigger = false
                    navigator.dismiss()
                }
            }
    }
}

private struct NavigationDismissModifierAll: ViewModifier {
    @Binding internal var trigger: Bool
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger {
                    self.trigger = false
                    _ = try? navigator.dismissAll()
               }
            }
    }
}

private struct NavigationLockedModifier: ViewModifier {
    @StateObject private var sentinel: NavigationLockedSentinal = .init()
    @Environment(\.navigator) private var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onAppear {
                sentinel.lock(navigator)
            }
    }
}

private class NavigationLockedSentinal: ObservableObject {
    private let id: UUID = UUID()
    private var state: NavigationState?
    deinit {
        state?.removeNavigationLock(id: id)
    }
    func lock(_ navigator: Navigator) {
        self.state = navigator.root.state
        self.state?.addNavigationLock(id: id)
    }
}
