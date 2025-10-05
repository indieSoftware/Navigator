//
//  HomeModuleDependencies.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/24/25.
//

import NavigatorUI
import SwiftUI

//
// HOME MODULE/FEATURE DEPENDENCIES
//

// Specify everything this module needs
public protocol HomeDependencies: CoreDependencies
    & HomeModuleDependencies
{}

// Specify everything required by this module
public protocol HomeModuleDependencies {
    var loader: any Loading { get }
    @MainActor var homeExternalViewProvider: any NavigationViewProviding<HomeExternalViews> { get }
    @MainActor var homeExternalRouter: any NavigationRouting<HomeExternalRoutes> { get }
}

// Construct defaults, including defaults that depend on other modules
extension HomeModuleDependencies where Self: CoreDependencies {
    // Using where Self: CoreDependencies illustrates accessing default dependencies from known dependencies.
    public var loader: any Loading {
        Loader(networker: networker)
    }
}

// Define our module's mock protocol
protocol MockHomeDependencies: HomeDependencies, MockCoreDependencies {}

// Provide missing defaults
extension MockHomeDependencies {
    // Mock a view we need to be provided from elsewhere
    @MainActor public var homeExternalViewProvider: any NavigationViewProviding<HomeExternalViews> {
        MockNavigationViewProvider()
    }
    // Mock a router
    @MainActor public var homeExternalRouter: any NavigationRouting<HomeExternalRoutes> {
        MockNavigationRouter()
    }
}

// Make our mock resolver
public class MockHomeResolver: MockCoreResolver, MockHomeDependencies {}

// Make our environment entry
extension EnvironmentValues {
    @Entry public var homeDependencies: HomeDependencies = MockHomeResolver()
}

// Demonstration of external routes that the home feature wants to trigger
nonisolated public enum HomeExternalRoutes: NavigationRoutes {
    case settingsPage2
    case settingsPage3
}
