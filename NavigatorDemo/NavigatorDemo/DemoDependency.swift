//
//  DemoDependency.swift
//  NavigatorDemo
//
//  Created by Michael Long on 12/5/24.
//

import SwiftUI
import Navigator

//
// CORE MODULE DEPENDENCIES
//

// Convenience type specifies everything visible and available in our core module
typealias CoreDependencies = NetworkDependencies
    & LoggingDependencies
    & AnalyticsDependencies

// Define a dependency
protocol NetworkDependencies {
    func networker() -> any Networking
}

// Provide a known default where we can
extension NetworkDependencies {
    func networker() -> any Networking {
        Networker()
    }
}

// Define a dependency
protocol LoggingDependencies {
    func logger() -> any Logging
}

// Provide a known default where we can
extension LoggingDependencies {
    func logger() -> any Logging {
        Logger()
    }
}

// Define a dependency
protocol AnalyticsDependencies {
    func analytics() -> any AnalyticsService
}

// Usually we'd provide a known default...
extension AnalyticsDependencies {
    // However, in this case we are NOT providing a default analytics service since we don't know what
    // that might be. As such it's up to main application to provide it.
    //
    // And since that definition is missing, it's required to do so.
}

//
// MOCK CORE DEPENDENCIES
//

// Extend our protocol for mocking purposes
protocol MockCoreDependencies: CoreDependencies {}

// Provide mock types
extension MockCoreDependencies {
    // override default provider
    func networker() -> any Networking {
        MockNetworker()
    }
    // provide missing service
    func analytics() -> any AnalyticsService {
        MockAnalyticsService()
    }
}

// Make our mock resolver
struct MockCoreResolver: MockCoreDependencies {}

// Make our environment entry
extension EnvironmentValues {
    @Entry var coreDependencies: CoreDependencies = MockCoreResolver()
}

//
// HOME MODULE/FEATURE DEPENDENCIES
//

// Specify everything this module needs
typealias HomeDependencies = CoreDependencies
    & HomeModuleDependencies

// Specify everything required by this module
protocol HomeModuleDependencies {
    func loader() -> any Loading
    @MainActor func homeExternalViewProvider() -> any ExternalNavigationViewProviding<HomeExternalViews>
    @MainActor func homeExternalRouter() -> any ExternalNavigationRouting<HomeExternalRoutes>
}

// Construct defaults, including defaults that depend on other modules
extension HomeModuleDependencies where Self: CoreDependencies {
    // Using where Self: CoreDependencies illustrates accessing default dependencies from known dependencies.
    func loader() -> any Loading {
        Loader(networker: networker())
    }
}

// Define our module's mock protocol
protocol MockHomeDependencies: HomeDependencies, MockCoreDependencies {}

// Provide missing defaults
extension MockHomeDependencies {
    // Mock a view we need to be provided from elsewhere
    @MainActor func homeExternalViewProvider() -> any ExternalNavigationViewProviding<HomeExternalViews> {
        MockExternalNavigationViewProvider()
    }
    // Mock a router
    @MainActor func homeExternalRouter() -> any ExternalNavigationRouting<HomeExternalRoutes> {
        MockExternalNavigationRouter()
    }
}

// Make our mock resolver
struct MockHomeResolver: MockHomeDependencies {}

// Make our environment entry
extension EnvironmentValues {
    @Entry var homeDependencies: HomeDependencies = MockHomeResolver()
}

// Demonstration of external routes that the home feature wants to trigger
enum HomeExternalRoutes: ExternalNavigationRoutes {
    case settingsPage2
    case settingsPage3
}

// Demonstration of external views that the home feature needs from somewhere
enum HomeExternalViews: ExternalNavigationViews {
    case external
}

//
// SETTINGS MODULE/FEATURE DEPENDENCIES
//

// Specify everything this module needs
typealias SettingsDependencies = CoreDependencies
    & SettingsModuleDependencies

// Specify everything specific to this module
protocol SettingsModuleDependencies {
    var settingsKey: String { get }
    func settingsProvider() -> any Loading
}

// Construct defaults, including defaults that depend on other modules
extension SettingsModuleDependencies where Self: CoreDependencies {
    // Using where Self: CoreDependencies illustrates accessing default dependencies from known dependencies.
    func settingsProvider() -> any Loading {
        Loader(networker: networker())
    }
}

// Define our module's mock protocol
protocol MockSettingsDependencies: SettingsDependencies, MockCoreDependencies {}

// Extend as needed
extension MockSettingsDependencies {
    var settingsKey: String { "mock" }
}

// Make our mock resolver
struct MockSettingsResolver: MockSettingsDependencies {}

// Illustrate making a test resolver that overrides default behavior
struct TestSettingsResolver: MockSettingsDependencies {
    var settingsKey: String { "test" }
}

// Make our environment entry
extension EnvironmentValues {
    @Entry var settingsDependencies: SettingsDependencies = MockSettingsResolver()
}

//
// APPLICATION DEPENDENCY RESOLVER
//

// Application aggregates all known module dependencies
typealias AppDependencies = CoreDependencies
    & HomeDependencies
    & SettingsDependencies

// Make the application's dependency resolver
class AppResolver: AppDependencies {
    // root navigator
    let navigator: Navigator
    // initializer
    init(navigator: Navigator) {
        self.navigator = navigator
    }
    // need one per app
    let analyticsService = ThirdPartyAnalyticsService()
    // Missing default dependencies forces app to provide them.
    func analytics() -> any AnalyticsService {
        analyticsService
    }
    // Home needs an external view from somewhere. Provide it.
    @MainActor func homeExternalViewProvider() -> any ExternalNavigationViewProviding<HomeExternalViews> {
        ExternalNavigationViewProvider {
            switch $0 {
            case .external:
                SettingsDestinations.external()
            }
        }
    }
    // Home feature wants to be able to route to settings feature, app knows how app is structured, so...
    @MainActor func homeExternalRouter() -> any ExternalNavigationRouting<HomeExternalRoutes> {
        ExternalNavigationRouter {
            switch $0 {
            case .settingsPage2:
                // Demonstrate routing with navigation actions
                self.navigator.perform(actions: [
                    .dismissAll,
                    .send(RootTabs.settings),
                    .with(RootTabs.settings.id) {
                        $0.popAll()
                        $0.push(SettingsDestinations.page2)
                    },
                ])
            case .settingsPage3:
                // Demonstrate routing sending raw navigation values
                self.navigator.send(values: [
                    NavigationAction.dismissAll,
                    RootTabs.settings,
                    NavigationAction.with(RootTabs.settings.id) {
                        $0.popAll()
                        $0.push(SettingsDestinations.page3)
                    },
                ])
            }
        }
    }
    // Missing default provides proper key
    var settingsKey: String { "actual" }
}

//
// MISCELLANEOUS SERVICE PROTOCOLS AND MOCKS
//

protocol Networking {
    func load<T>() -> T?
}

struct Networker: Networking {
    func load<T>() -> T? {
        // demo only returns strings
        "(A)" as? T
    }
}

class MockNetworker: Networking {
    // Extremely simple way to expose a single factory for testing
    nonisolated(unsafe) static var factory: Any = { "(M)" }
    func load<T>() -> T? {
        if let factory = Self.factory as? () -> T {
            return factory()
        }
        return nil
    }
}

extension MockCoreDependencies {
    func mock<T>(_ factory: @escaping () -> T) -> Self {
        MockNetworker.factory = factory
        return self
    }
}

protocol Loading {
    func load() -> String
}

struct Loader: Loading {
    let networker: Networking
    func load() -> String {
        networker.load() ?? "?"
    }
}

protocol AnalyticsService {
    func event(_ event: String)
}

class ThirdPartyAnalyticsService: AnalyticsService {
    func event(_ event: String) {
        print(event)
    }
}

struct MockAnalyticsService: AnalyticsService {
    func event(_ event: String) {
        print(event)
    }
}

protocol Logging {
    func log(_ message: String)
}

struct Logger: Logging {
    func log(_ message: String) {
        print(message)
    }
}

protocol SettingsProviding {
    func settings() -> [String]
}

struct SettingsProvider: SettingsProviding {
    func settings() -> [String] {
        []
    }
}

