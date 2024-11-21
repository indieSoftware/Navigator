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

    @Environment(\.navigator) var parent: Navigator
    @Environment(\.dismiss) var action: DismissAction

    func body(content: Content) -> some View {
        content
            .modifier(WrappedDismissibleModifier(parent: parent, action: action))
    }
    
    struct WrappedDismissibleModifier:  ViewModifier {

        @StateObject private var navigator: Navigator

        init(parent: Navigator, action: DismissAction) {
            self._navigator = .init(wrappedValue: .init(parent: parent, action: action))
        }

        func body(content: Content) -> some View {
            content
                .sheet(item: $navigator.sheet ) { destination in
                    destination.asView()
                }
                .fullScreenCover(item: $navigator.fullScreenCover) { destination in
                    destination.asView()
                }
                .environment(\.navigator, navigator)
        }

    }
    
}
