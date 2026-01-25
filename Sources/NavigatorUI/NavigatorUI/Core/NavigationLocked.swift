//
//  NavigationLocked.swift
//  Navigator
//
//  Created by Michael Long on 11/30/24.
//

import SwiftUI

extension Navigator {

    /// Returns true if navigation is locked.
    public var isNavigationLocked: Bool {
        !root.navigationLocks.isEmpty
    }

    internal func addNavigationLock(id: UUID) {
        root.navigationLocks.insert(id)
    }

    internal func removeNavigationLock(id: UUID) {
        root.navigationLocks.remove(id)
    }

}

extension View {

    /// Apply to a presented view on which you want to prevent global dismissal.
    @MainActor public func navigationLocked() -> some View {
        self.modifier(NavigationLockedModifier())
    }

}

private struct NavigationLockedModifier: ViewModifier {

    @State private var sentinel: NavigationLockedSentinel = .init()
    @Environment(\.navigator) private var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .task {
                sentinel.lock(navigator)
            }
    }

}

private final class NavigationLockedSentinel {

    private let id: UUID = UUID()
    private var navigator: Navigator?

    deinit {
        let id = self.id
        let navigator = self.navigator
        MainActor.assumeIsolated {
            navigator?.removeNavigationLock(id: id)
        }
    }

    @MainActor
    func lock(_ navigator: Navigator) {
        self.navigator = navigator.root
        self.navigator?.addNavigationLock(id: id)
    }

}
