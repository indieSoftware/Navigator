//
//  NavigationDismissible.swift
//  Navigator
//
//  Created by Michael Long on 11/13/24.
//

import SwiftUI

extension View {
    public func navigationDismissible() -> some View {
        self.modifier(NavigationDismissibleModifier())
    }
}

struct NavigationDismissibleModifier: ViewModifier {

    @Environment(\.navigator) var navigator: Navigator
    @Environment(\.dismiss) var action: DismissAction

    func body(content: Content) -> some View {
        content
            .modifier(WrappedDismissibleModifier(navigator: navigator, action: action))
    }
    
    struct WrappedDismissibleModifier:  ViewModifier {

        init(navigator: Navigator, action: DismissAction) {
            navigator.setDismissAction(action)
        }

        func body(content: Content) -> some View {
            content
        }

    }
    
}
