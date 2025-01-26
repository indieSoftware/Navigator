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
public protocol NavigationURLHandler {
    /// Method examines the passed URL, parses the values, and routes it as needed.
    ///
    /// If a given handler doesn't recognize the URL in question, it returns false. Handlers are processed in order until the URL is recognized
    /// or until recognition fails.
    @MainActor func handles(_ url: URL, with navigator: Navigator) -> Bool
}

extension View {
    /// Adds Deep Linking support to an application.
    ///
    /// The `onNavigationOpenURL` modifier adds an `onOpenURL` modifier to a view and translates the incoming URL to a set of destinations
    /// using the provided set of NavigationURLHanders.
    /// ```swift
    /// .onNavigationOpenURL(handlers: [
    ///     HomeURLHander(router: router),
    ///     SettingsURLHander(router: router)
    /// ])
    ///```
    public func onNavigationOpenURL(handlers: [any NavigationURLHandler]) -> some View {
        self.modifier(OnNavigationOpenURLModifier(handlers: handlers))
    }
}

private struct OnNavigationOpenURLModifier: ViewModifier {

    private let handlers: [any NavigationURLHandler]

    @Environment(\.navigator) var navigator: Navigator

    init(handlers: [any NavigationURLHandler]) {
        self.handlers = handlers
    }

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                for handler in handlers {
                    if handler.handles(url, with: navigator) {
                        break
                    }
                }
            }
    }

}
