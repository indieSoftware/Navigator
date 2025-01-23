//
//  NavigationPresentation.swift
//  Navigator
//
//  Created by Michael Long on 1/22/25.
//

import SwiftUI

extension Navigator {

    /// Convenience method resents a sheet
    @MainActor
    public func present(sheet: any NavigationDestination) {
        navigate(to: sheet, method: .sheet)
    }

    /// Convenience method resents a cover
    @MainActor
    public func present(cover: any NavigationDestination) {
        navigate(to: cover, method: .cover)
    }

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isPresenting: Bool {
        state.isPresenting
    }

    /// Returns true if any child of the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isAnyChildPresenting: Bool {
        state.isAnyChildPresenting
    }

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presented.
    public nonisolated var isPresented: Bool {
        state.isPresented
    }

}

extension NavigationState {

    internal nonisolated var isPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false }) != nil
    }

    internal nonisolated var isAnyChildPresenting: Bool {
        children.values.first(where: {
            if let object = $0.object, object.isPresented || object.isAnyChildPresenting {
                return true
            }
            return false
        }) != nil
    }

}

internal struct NavigationPresentationModifiers: ViewModifier {

    @ObservedObject internal var state: NavigationState
    @Environment(\.dismiss) private var dismiss: DismissAction

    func body(content: Content) -> some View {
        content
            .sheet(item: $state.sheet) { (destination) in
                ManagedPresentationView {
                    destination()
                }
            }
            #if os(iOS)
            .fullScreenCover(item: $state.cover) { (destination) in
                ManagedPresentationView {
                    destination()
                }
            }
            #endif
            .onChange(of: state.triggerDismiss) { trigger in
                if trigger {
                    dismiss()
                }
            }
    }

}
