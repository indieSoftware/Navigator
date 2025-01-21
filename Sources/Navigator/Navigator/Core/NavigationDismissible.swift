//
//  NavigationDismissible.swift
//  Navigator
//
//  Created by Michael Long on 11/13/24.
//

import SwiftUI

extension View {

    /// Allows presented views not in a navigation stack to be dismissed using a Navigator.
    ///
    /// Also supports nested sheets and covers.
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
            .sheet(item: $state.sheet) { (destination) in
                destination()
            }
            #if os(iOS)
            .fullScreenCover(item: $state.cover) { (destination) in
                destination()
            }
            #endif
            .onChange(of: state.triggerDismiss) { trigger in
                if trigger {
                    dismiss()
                }
            }
            .environment(\.navigator, Navigator(state: state, parent: parent, isPresented: true))
    }

}
