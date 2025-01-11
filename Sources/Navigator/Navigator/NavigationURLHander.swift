//
//  NavigationURLHander.swift
//  Navigator
//
//  Created by Michael Long on 11/21/24.
//

import SwiftUI

/// Provides Deep Linking support.
///
/// A NavigationURLHander examines the passed URL and converts it into a set of NavigationDestination or Hashable values
/// that can be broadcast throughout the application using `navigator.send(values:)`.
/// ```swift
/// .onNavigationOpenURL(handlers: [
///     HomeURLHander(),
///     SettingsURLHander()
/// ])
///```
/// Developers can add `.onNavigationReceive` modifiers to their code to listen for specific types and perform specific actions when they're
/// received.
///
/// For example, a URL like "navigator://app/settings" can be translated by the SettingsURLHander into `[RootTabs.settings]`, which can then
/// broadcast and received to set the selected tab in a given view.
/// ```swift
/// .onNavigationReceive { (tab: RootTabs) in
///     selectedTab = tab
///     return .auto
/// }
///```
public protocol NavigationURLHander {
    /// Method examines the passed URL and converts it into a set of NavigationDestination or Hashable values.
    ///
    /// Those values will then be broadcast throughout the application using `navigator.send(values:)`.
    ///
    /// If a given handler doesn't recognize the URL in question, it returns nil. Handlers are processed in order until the URL is recognized
    /// or until recognition fails.
    @MainActor func handles(_ url: URL) -> [any Hashable]?
}

extension View {
    /// Adds Deep Linking support to an application.
    ///
    /// The `onNavigationOpenURL` modifier adds an `onOpenURL` modifier to a view and translates the incoming URL to a set of destinations
    /// using the provided set of NavigationURLHanders.
    /// ```swift
    /// .onNavigationOpenURL(handlers: [
    ///     HomeURLHander(),
    ///     SettingsURLHander()
    /// ])
    ///```
    public func onNavigationOpenURL(handlers: [any NavigationURLHander]) -> some View {
        self.modifier(OnNavigationOpenURLModifier(handlers: handlers))
    }
}

private struct OnNavigationOpenURLModifier: ViewModifier {

    private let handlers: [any NavigationURLHander]

    @Environment(\.navigator) var navigator: Navigator

    init(handlers: [any NavigationURLHander]) {
        self.handlers = handlers
    }

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                for handler in handlers {
                    if let destinations = handler.handles(url) {
                        return navigator.send(values: destinations)
                    }
                }
            }
    }

}
