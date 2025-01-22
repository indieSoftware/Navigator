//
//  ManagedPresentationView.swift
//  Navigator
//
//  Created by Michael Long on 1/22/25.
//

import SwiftUI

@MainActor
public struct ManagedPresentationView<Content: View>: View {

    @Environment(\.navigator) private var parent: Navigator
    @Environment(\.isPresented) private var isPresented

    @StateObject private var state: NavigationState

    private let content: Content

    /// Initializes NavigationStack
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self._state = .init(wrappedValue: .init(owner: .presenter, name: nil))
    }

    public var body: some View {
        content
            .modifier(NavigationPresentationModifiers(state: state))
            .environment(\.navigator, Navigator(state: state, parent: parent, isPresented: isPresented))
    }

}

extension View {

    /// Allows presented views not in a navigation stack to be dismissed using a Navigator.
    ///
    /// Also supports nested sheets and covers.
    public func managedPresentationView() -> some View {
        ManagedPresentationView {
            self
        }
    }

    /// Allows presented views not in a navigation stack to be dismissed using a Navigator.
    @available(*, deprecated, renamed: "managedPresentationView", message: "Use `managedPresentationView()` instead.")
    public func navigationDismissible() -> some View {
        ManagedPresentationView {
            self
        }
    }

}
