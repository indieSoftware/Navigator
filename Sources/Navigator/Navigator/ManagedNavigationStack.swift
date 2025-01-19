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

    @Environment(\.navigator) private var parent: Navigator
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.isPresented) private var isPresented
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var state: NavigationState
    @SceneStorage private var sceneStorage: Data?

    private let name: String?
    private let content: Content
    private let isScene: Bool

    /// Initializes NavigationStack
    public init(@ViewBuilder content: () -> Content) {
        self.name = nil
        self.content = content()
        self._sceneStorage = .init("ManagedNavigationStack.*")
        self._state = .init(wrappedValue: .init(name: nil))
        self.isScene = false
    }

    /// Initializes named NavigationStack
    public init(name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
        self._sceneStorage = .init("ManagedNavigationStack.\(name)")
        self._state = .init(wrappedValue: .init(name: name))
        self.isScene = false
    }

    /// Initializes NavigationStack with name needed to enable scene storage.
    public init(scene name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
        self._sceneStorage = .init("ManagedNavigationStack.\(name)")
        self._state = .init(wrappedValue: .init(name: name))
        self.isScene = true
    }

// Researching needs and ramifications of the following.
//
//    /// Initializes NavigationStack with externally provided navigator.
//    public init(navigator: Navigator, isScene: Bool = false, @ViewBuilder content: () -> Content) {
//        self.name = navigator.name
//        self.content = content()
//        self._sceneStorage = .init("ManagedNavigationStack.\(navigator.name ?? "*")")
//        self._state = .init(wrappedValue: navigator.state)
//        self.isScene = isScene && navigator.name != nil
//    }
//

    public var body: some View {
        NavigationStack(path: $state.path) {
            content
        }
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
        .onChange(of: scenePhase) { phase in
            guard isScene else {
                return
            }
            if phase == .active, let data = sceneStorage {
                state.restore(from: data)
            } else {
                sceneStorage = state.encoded()
            }
        }
        .environment(\.navigator, Navigator(state: state, parent: parent, isPresented: isPresented))
    }

}
