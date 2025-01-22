//
//  NavigationPresentation.swift
//  Navigator
//
//  Created by Michael Long on 1/22/25.
//

import SwiftUI

extension Navigator {

    /// Returns true if the current ManagedNavigationStack or navigationDismissible is presenting.
    public nonisolated var isPresenting: Bool {
        state.isPresenting
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
