//
//  SettingsModuleDependencies.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/24/25.
//

import NavigatorUI
import SwiftUI

//
// SETTINGS MODULE/FEATURE DEPENDENCIES
//

// Specify everything this module needs
public protocol SettingsDependencies: CoreDependencies
    & SettingsModuleDependencies
{}

// Specify everything specific to this module
public protocol SettingsModuleDependencies {
    var settingsKey: String { get }
    var settingsProvider: any Loading { get }
}

// Construct defaults, including defaults that depend on other modules
extension SettingsModuleDependencies where Self: CoreDependencies {
    // Using where Self: CoreDependencies illustrates accessing default dependencies from known dependencies.
    public var settingsProvider: any Loading {
        Loader(networker: networker)
    }
}

// Define our module's mock protocol
public protocol MockSettingsDependencies: SettingsDependencies, MockCoreDependencies {}

// Extend as needed
extension MockSettingsDependencies {
    public var settingsKey: String { "mock" }
}

// Make our mock resolver
public class MockSettingsResolver: MockCoreResolver, MockSettingsDependencies {}

// Illustrate making a test resolver that overrides default behavior
public struct TestSettingsResolver: MockSettingsDependencies {
    public let cache: DependencyCache = .init()
    public var settingsKey: String { "test" }
}

// Make our environment entry
extension EnvironmentValues {
    @Entry public var settingsDependencies: SettingsDependencies = MockSettingsResolver()
}

