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

private struct NavigationDismissibleModifier: ViewModifier {

    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.navigator) var parent: Navigator

    @StateObject private var state: NavigationState = .init()

    func body(content: Content) -> some View {
        content
            .onChange(of: state.triggerDismiss) { trigger in
                if trigger {
                    dismiss()
                }
            }
            .environment(\.navigator, Navigator(state: state, parent: parent, isPresented: true))
    }

}
