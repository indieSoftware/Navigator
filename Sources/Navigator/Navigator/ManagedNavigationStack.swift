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
    @Environment(\.isPresented) private var isPresented

    private var name: StackName?
    private var content: Content

    /// Initializes NavigationStack
    public init(@ViewBuilder content: () -> Content) {
        self.name = nil
        self.content = content()
    }

    /// Initializes named NavigationStack
    public init(name name: String, @ViewBuilder content: () -> Content) {
        self.name = .name(name)
        self.content = content()
    }

    /// Initializes NavigationStack with name needed to enable scene storage.
    public init(scene name: String, @ViewBuilder content: () -> Content) {
        self.name = .scene(name)
        self.content = content()
    }

    public var body: some View {
        WrappedView(name: name, parent: parent, isPresented: isPresented, content: content)
    }

    // Wrapped view allows parent environment variables to be extracted and passed to navigator.
    private struct WrappedView: View {

        @StateObject private var navigator: Navigator
        @SceneStorage private var sceneStorage: Data?
        
        @Environment(\.dismiss) private var dismiss: DismissAction
        @Environment(\.scenePhase) private var scenePhase

        private let name: StackName?
        private let content: Content

        init(name: StackName?, parent: Navigator, isPresented: Bool, content: Content) {
            self.name = name
            self._sceneStorage = .init("ManagedNavigationStack.\(name?.string ?? "*")")
            self._navigator = .init(wrappedValue: .init(name: name?.string, parent: parent, isPresented: isPresented))
            self.content = content
        }

        public var body: some View {
            NavigationStack(path: $navigator.path) {
                content
                    .sheet(item: $navigator.sheet) { (destination) in
                        destination()
                    }
                    #if os(iOS)
                    .fullScreenCover(item: $navigator.cover) { (destination) in
                        destination()
                    }
                    #endif
                    .onChange(of: navigator.triggerDismiss) { _ in
                        dismiss()
                    }
                    .onChange(of: scenePhase) { phase in
                        guard case .scene(let name) = name else {
                            return
                        }
                        if phase == .active, let data = sceneStorage {
                            navigator.restore(from: data)
                        } else {
                            sceneStorage = navigator.encoded()
                        }
                    }
            }
            .environment(\.navigator, navigator)
        }

    }

    private enum StackName {
        case name(String)
        case scene(String)
        var string: String {
            switch self {
            case .name(let name): name
            case .scene(let name): name
            }
        }
    }

}
