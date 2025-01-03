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

// Specify everything specific to this module
protocol HomeModuleDependencies {
    func loader() -> any Loading
    var homeValue: Int { get }
}

// Construct defaults, including defaults that depend on other modules
extension HomeModuleDependencies where Self: CoreDependencies {
    // Using where Self: CoreDependencies illustrates accessing default dependencies from known dependencies.
    func loader() -> any Loading {
        Loader(networker: networker())
    }
    var homeValue: Int { 66 }
}

// Define our module's mock protocol
protocol MockHomeDependencies: HomeDependencies, MockCoreDependencies {}

// Make our mock resolver
struct MockHomeResolver: MockHomeDependencies {}

// Make our environment entry
extension EnvironmentValues {
    @Entry var homeDependencies: HomeDependencies = MockHomeResolver()
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
    // need one per app
    let analyticsService = ThirdPartyAnalyticsService()
    // Missing default dependencies forces app to provide them.
    func analytics() -> any AnalyticsService {
        analyticsService
    }
    // Missing default provides proper key
    var settingsKey: String { "actual" }
}

//
// MISCELLANEOUS SERVICE PROTOCOLS AND MOCKS
//

protocol Networking {
    func load() -> String
}

struct Networker: Networking {
    func load() -> String { "(A)" }
}

class MockNetworker: Networking {
    // Extremely simple way to expose a variable for testing
    // MockNetworker.value = "test"
    nonisolated(unsafe) static var value: String = "(M)"
    func load() -> String { Self.value }
}

protocol Loading {
    func load() -> String
}

struct Loader: Loading {
    let networker: Networking
    func load() -> String {
        networker.load()
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

