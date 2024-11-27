//
//  NavigationDismiss.swift
//  Navigator
//
//  Created by Michael Long on 11/27/24.
//

import SwiftUI

extension Navigator {

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

    @MainActor
    @discardableResult
    public func dismissAll() -> Bool {
        root.dismissAllChildren()
    }

    @MainActor
    @discardableResult
    public func dismissAllChildren() -> Bool {
        for child in children.values {
            if let navigator = child.object, navigator.dismiss() || navigator.dismissAllChildren() {
                return true
            }
        }
        return false
    }

}

extension Navigator {

    public nonisolated var isPresented: Bool {
        dismissible ?? false
    }

    public nonisolated var isPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false }) != nil
    }

    public nonisolated var isChildPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false || $0.object?.isChildPresenting ?? false }) != nil
    }

}

extension View {
    public func navigationDismiss(trigger: Binding<Bool>) -> some View {
        self.modifier(NavigationDismissModifier(trigger: trigger))
    }
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
                if trigger {
                    navigator.dismiss()
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
                if trigger {
                    navigator.dismissAll()
                    self.trigger = false
                }
            }
    }
}
