//
//  NavigationDismissible.swift
//  Navigator
//
//  Created by Michael Long on 11/13/24.
//

import SwiftUI

extension View {

    /// Allows presented views to be dismissed using a Navigator.
    public func navigationDismissible() -> some View {
        self.modifier(NavigationDismissibleModifier())
    }

}

struct NavigationDismissibleModifier: ViewModifier {

    @Environment(\.navigator) var parent: Navigator

    func body(content: Content) -> some View {
        content
            .modifier(WrappedModifier(parent: parent))
    }
    
    // Wrapped modifier allows parent environment variables can be extracted and passed to navigator.
    struct WrappedModifier:  ViewModifier {

        @StateObject private var navigator: Navigator
        @Environment(\.dismiss) var dismiss: DismissAction

        init(parent: Navigator) {
            self._navigator = .init(wrappedValue: .init(parent: parent, isPresented: true))
        }

        func body(content: Content) -> some View {
            content
                .onChange(of: navigator.triggerDismiss) { _ in
                    dismiss()
                }
                .environment(\.navigator, navigator)
        }

    }

}
