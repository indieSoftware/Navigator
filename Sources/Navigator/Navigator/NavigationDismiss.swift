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
        if isPresented {
            triggerDismiss = true
            log("Navigator dimsissing: \(id)")
            return true
        }
        return false
    }

    /// Dismisses presented sheet or fullScreenCover views presented by this Navigator.
    @MainActor
    public func dismissPresentedViews() {
        sheet = nil
        cover = nil
    }

    /// Returns to the root Navigator and dismisses *any* presented ManagedNavigationStack.
    @MainActor
    @discardableResult
    public func dismissAll() -> Bool {
        root.dismissAllChildren()
    }

    /// Dismisses *any* ManagedNavigationStack or navigationDismissible presented by any child of this Navigator.
    @MainActor
    @discardableResult
    public func dismissAllChildren() -> Bool {
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

    /// Returns to the root Navigator, dismisses *any* presented ManagedNavigationStacks, and resets navigation paths.
    @MainActor
    @discardableResult
    public func resetAll() -> Bool {
        let dismissed = root.dismissAllChildren()
        let popped = root.popAllChildren()
        return dismissed || popped
    }

    @MainActor
    internal func popAllChildren() -> Bool {
        var popped = false
        if !path.isEmpty {
            popAll()
            popped = true
        }
        for child in children.values {
            if let navigator = child.object, navigator.popAllChildren() {
                popped = true
            }
        }
        return popped
    }

}

extension Navigator {

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false }) != nil
    }

    /// Returns true if a child of the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isChildPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false || $0.object?.isChildPresenting ?? false }) != nil
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

}

private struct NavigationDismissModifier: ViewModifier {
    @Binding internal var trigger: Bool
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger && navigator.dismiss() {
                    self.trigger = false
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
                if trigger && navigator.dismissAll() {
                    self.trigger = false
                }
            }
    }
}
