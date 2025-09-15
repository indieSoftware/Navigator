//
//  AnyNavigationDestination.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

/// Wrapper boxes a specific NavigationDestination.
public struct AnyNavigationDestination {
    public var wrapped: any NavigationDestination
    public var method: NavigationMethod

    @MainActor
    init<D: NavigationDestination>(_ destination: D) {
        self.wrapped = destination
        self.method = destination.method
    }

    init(wrapped: any NavigationDestination, method: NavigationMethod) {
        self.wrapped = wrapped
        self.method = method
    }
}

extension AnyNavigationDestination: Identifiable {

    public nonisolated var id: Int { wrapped.id }

    @MainActor public func callAsFunction() -> AnyView {
        wrapped.asAnyView()
    }

}

extension AnyNavigationDestination: Hashable, Equatable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func == (lhs: AnyNavigationDestination, rhs: AnyNavigationDestination) -> Bool {
        lhs.id == rhs.id
    }

}

extension AnyNavigationDestination {
    @MainActor
    internal func mappedNavigationView(for state: NavigationState) -> AnyView {
        let mapped = state.navigationMap?(wrapped) ?? wrapped
        if let modifier = state.navigationModifier {
            return AnyView(modifier(mapped))
        } else {
            return mapped.asAnyView()
        }
    }

    @MainActor
    internal func mappedPresentationView(for state: NavigationState) -> AnyView {
        let mapped = state.navigationMap?(wrapped) ?? wrapped
        if let modifier = state.presentationModifier {
            return AnyView(modifier(mapped))
        } else {
            return mapped.asAnyView()
        }
    }
}

extension View {

    /// Enables/disables auto destination mode.
    /// ```swift
    /// // auto destination mode allows this..
    /// struct SettingsTabView: View {
    ///     var body: some View {
    ///         ManagedNavigationStack {
    ///             SettingsView()
    ///         }
    ///     }
    /// }
    ///
    /// // verses this...
    /// struct SettingsTabView: View {
    ///     var body: some View {
    ///         ManagedNavigationStack {
    ///             SettingsView()
    ///                 .navigationDestination(SettingsDestinations.self)
    ///                 .navigationDestination(ProfileDestinations.self)
    ///                 .navigationDestination(OptionsDestinations.self)
    ///         }
    ///     }
    /// }
    /// ```
    /// When enabled, explicit navigationDestination registrations are not required for any `NavigationDestination` type. Just navigate to
    /// that value.
    /// ```swift
    /// Button("Button Navigate to Page 55") {
    ///     navigator.navigate(to: UnregisteredDestination.pageN(55))
    /// }
    /// ```
    /// This even works with `NavigationLink(value:label)`!
    /// ```swift
    /// import NavigatorUI
    ///
    /// NavigationLink(value: UnregisteredDestination.page3) {
    ///     Text("Link to Page 3!")
    /// }
    /// ```
    /// Just make sure you import NavigatorUI in your code.
    /// 
    /// You can also enable/disable auto destination mode for all managed navigation stacks in the configuration settings.
    /// ```swift
    /// @main
    /// struct NavigatorDemoApp: App {
    ///     let navigator = Navigator(configuration: .init(restorationKey: "1.0.0", autoDestinationMode: true)
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             RootTabView()
    ///                 .navigationRoot(navigator)
    ///         }
    ///     }
    /// }
    /// ```
    @MainActor
    public func navigationAutoDestinationMode(_ enabled: Bool) -> some View {
        self.modifier(NavigationAutoDestinationModeModifier(enabled: enabled))
    }

}

private struct NavigationAutoDestinationModeModifier: ViewModifier {
    @Environment(\.navigator) private var navigator
    var enabled: Bool
    public func body(content: Content) -> some View {
        content
            .onAppear {
                navigator.state.autoDestinationModeOverride = enabled
            }
    }
}

extension AnyNavigationDestination: Codable {

    // Adapted from https://www.pointfree.co/blog/posts/78-reverse-engineering-swiftui-s-navigationpath-codability

    // convert data to NavigationDestination
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let typeName = try container.decode(String.self)
        let type = _typeByName(typeName)
        guard let type = type as? any Decodable.Type else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(typeName) is not decodable.")
        }
        guard let destination = (try container.decode(type)) as? any NavigationDestination else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(typeName) is not decodable.")
        }
        wrapped = destination
        method = try container.decode(NavigationMethod.self)
    }

    // convert NavigationDestination to storable data
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(_mangledTypeName(type(of: wrapped)))
        guard let element = wrapped as? any Encodable else {
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "\(type(of: wrapped)) is not encodable.")
            throw EncodingError.invalidValue(wrapped, context)
        }
        try container.encode(element)
    }

}
