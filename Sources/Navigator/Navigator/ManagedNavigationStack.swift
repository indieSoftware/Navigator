//
//  ManagedNavigationStack.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

@MainActor
public struct ManagedNavigationStack<Content: View>: View {

    @Environment(\.navigator) private var parent: Navigator

    private var content: Content

    /// Initializes NavigationStack without Navigator
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    public var body: some View {
        WrappedNavigationStack(parent: parent, content: content)
    }

    // Wrapped view exists so environment variables can be extracted and passed to navigator.
    private struct WrappedNavigationStack: View {

        @StateObject private var navigator: Navigator
        private let content: Content

        init(parent: Navigator, content: Content) {
            self._navigator = .init(wrappedValue: .init(parent: parent))
            self.content = content
        }

        public var body: some View {
            NavigationStack(path: $navigator.path) {
                content
            }
            .sheet(item: $navigator.sheet ) { destination in
                destination.asView
            }
            .fullScreenCover(item: $navigator.fullScreenCover) { destination in
                destination.asView
            }
            .environment(\.navigator, navigator)
        }
    }

}

public struct WithNavigator<Content: View>: View {

    @Environment(\.navigator) private var navigator: Navigator
    private var content: (Navigator) -> Content
    
    public init(@ViewBuilder content: @escaping (Navigator) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(navigator)
    }
}
