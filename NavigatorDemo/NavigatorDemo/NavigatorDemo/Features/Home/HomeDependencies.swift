//
//  HomeModuleDependencies.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/24/25.
//

import Navigator
import SwiftUI

//
// HOME MODULE/FEATURE DEPENDENCIES
//

// Specify everything this module needs
public typealias HomeDependencies = CoreDependencies
    & HomeModuleDependencies

// Specify everything required by this module
public protocol HomeModuleDependencies {
    func loader() -> any Loading
    @MainActor func homeExternalViewProvider() -> any ExternalNavigationViewProviding<HomeExternalViews>
    @MainActor func homeExternalRouter() -> any ExternalNavigationRouting<HomeExternalRoutes>
}

// Construct defaults, including defaults that depend on other modules
extension HomeModuleDependencies where Self: CoreDependencies {
    // Using where Self: CoreDependencies illustrates accessing default dependencies from known dependencies.
    public func loader() -> any Loading {
        Loader(networker: networker())
    }
}

// Define our module's mock protocol
protocol MockHomeDependencies: HomeDependencies, MockCoreDependencies {}

// Provide missing defaults
extension MockHomeDependencies {
    // Mock a view we need to be provided from elsewhere
    @MainActor public func homeExternalViewProvider() -> any ExternalNavigationViewProviding<HomeExternalViews> {
        MockExternalNavigationViewProvider()
    }
    // Mock a router
    @MainActor public func homeExternalRouter() -> any ExternalNavigationRouting<HomeExternalRoutes> {
        MockExternalNavigationRouter()
    }
}

// Make our mock resolver
public struct MockHomeResolver: MockHomeDependencies {}

// Make our environment entry
extension EnvironmentValues {
    @Entry public var homeDependencies: HomeDependencies = MockHomeResolver()
}

// Demonstration of external routes that the home feature wants to trigger
public enum HomeExternalRoutes: ExternalNavigationRoutes {
    case settingsPage2
    case settingsPage3
}

// Demonstration of external views that the home feature needs from somewhere
public enum HomeExternalViews: ExternalNavigationViews {
    case external
}
