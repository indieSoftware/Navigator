//
//  NavigationConfiguration.swift
//  Navigator
//
//  Created by Michael Long on 12/1/24.
//

import SwiftUI

/// Configuration options for Navigator.
///
/// Allows the developer to modify some of Navigator's basic behavior by configuring and installing a
/// root Navigator in the application's navigation tree.
/// ```swift
/// @main
/// struct NavigatorDemoApp: App {
///     var body: some Scene {
///         WindowGroup {
///             RootTabView()
///                 .environment(\.navigator, Navigator(configuration: configuration))
///         }
///     }
///     var configuration: NavigationConfiguration {
///         .init(restorationKey: "1.0.0", verbosity: .info)
///     }
/// }
/// ```
public struct NavigationConfiguration {

    /// Provide a restorationKey to enable state restoration in named ManagedNavigationControllers.
    ///
    /// Increment or change the key when adding/removing checkpoints or changing destination types.
    ///
    /// If no restorationKey is provided then navigation state restoration is disabled.
    public let restorationKey: String?


    /// Allows the developer to log navigation messages to the console or to their own logging system.
    ///
    /// If logger is nil then nothing is logged.
    public let logger: ((_ message: String) -> Void)?

    /// Logging verbosity
    public let verbosity: Verbosity

    public init(
        restorationKey: String? = nil,
        logger: ((String) -> Void)? = { print($0) },
        verbosity: Verbosity = .warning
    ) {
        self.restorationKey = restorationKey
        self.logger = logger
        self.verbosity = verbosity
    }

    public enum Verbosity: Int {
        case info
        case warning
        case error
        case none
    }

}
