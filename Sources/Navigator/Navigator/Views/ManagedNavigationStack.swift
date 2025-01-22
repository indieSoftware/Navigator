//
//  ManagedNavigationStack.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

/// Creates a NavigationStack and its associated Navigator that "manages" the stack.
///
/// Using ManagedNavigationStack is easy. Just use it where you'd normally used a `NavigationStack`.
/// ```swift
/// struct RootView: View {
///     var body: some View {
///         ManagedNavigationStack {
///             HomeView()
///                 .navigationDestination(HomeDestinations.self)
///         }
///     }
/// }
/// ```
/// ### Dismissible
/// Presented ManagedNavigationStacks are automatically dismissible.
/// ### State Restoration
/// ManagedNavigationStack supports state restoration out of the box. For state restoration to work, however, a
/// few conditions apply.
/// 
/// 1.  The ManagedNavigationStack must have a unique scene name.
/// 2.  All ``NavigationDestination`` types pushed onto the stack must be Codable.
/// 3.  A state restoration key was provided in ``NavigationConfiguration``.
///
/// See the State Restoration documentation for more.
@MainActor
public struct ManagedNavigationStack<Content: View>: View {

    @Environment(\.navigator) private var navigator: Navigator
    @Environment(\.isPresented) private var isPresented

    private let name: String?
    private let content: Content
    private let isScene: Bool

    /// Initializes NavigationStack
    public init(@ViewBuilder content: () -> Content) {
        self.name = nil
        self.content = content()
        self.isScene = false
    }

    /// Initializes named NavigationStack
    public init(name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
        self.isScene = false
    }

    /// Initializes NavigationStack with name needed to enable scene storage.
    public init(scene name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
        self.isScene = true
    }

    public var body: some View {
        if isWrappedInPresentationView {
            WrappedNavigationStack(state: navigator.state.setting(name), name: sceneName, content: content)
        } else {
            NewNavigationStack(state: .init(owner: .stack, name: name), name: sceneName, content: content)
        }
    }

    internal var isWrappedInPresentationView: Bool {
        isPresented && navigator.state.owner == .presenter
    }

    internal var sceneName: String? {
        isScene ? name : nil
    }

    // Allows NavigationStack to use NavigationState provided by ManagedPresentationView
    internal struct WrappedNavigationStack: View {

        @ObservedObject internal var state: NavigationState
        internal let name: String?
        internal let content: Content

        var body: some View {
            NavigationStack(path: $state.path) {
                content
            }
            .modifier(NavigationSceneStorageModifier(state: state, name: name))
        }

    }

    // Allow NavigationStack to create and manage its own NavigationState
    internal struct NewNavigationStack: View {

        @StateObject internal var state: NavigationState
        internal let name: String?
        internal let content: Content

        @Environment(\.navigator) private var parent
        @Environment(\.isPresented) private var isPresented

        var body: some View {
            NavigationStack(path: $state.path) {
                content
            }
            .modifier(NavigationPresentationModifiers(state: state))
            .modifier(NavigationSceneStorageModifier(state: state, name: name))
            .environment(\.navigator, Navigator(state: state, parent: parent, isPresented: isPresented))
         }

    }

}

// RootNavigator
// - isPresented == false
//
// ManagedNavigationStack
// - isPresented == false
// - Needs New Navigator
// - Provides sheets
//
// -----------------------------
//
// PresentedView
// - isPresented == true
// - Provides New Navigator
// - Provides sheets
//
//   ManagedNavigationStack
//   - Uses Existing Navigator if PresentedView
//   - Uses Existing Sheets
//
// -----------------------------
//
// PresentedView
// - isPresented == true
// - Provides New Navigator
// - Provides sheets
//
//   ManagedNavigationStack
//   - Uses Existing Navigator
//   - Uses Existing Sheets
//
// -----------------------------
//
// PresentedView
// - isPresented == true
// - Provides New Navigator
// - Provides sheets
//
//   SomeView
//   - Uses Existing Navigator
//   - Uses Existing Sheets
//
