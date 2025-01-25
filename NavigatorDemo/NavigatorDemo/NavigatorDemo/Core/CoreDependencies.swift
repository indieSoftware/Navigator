//
//  Dependencies.swift
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
public typealias CoreDependencies = NetworkDependencies
    & LoggingDependencies
    & AnalyticsDependencies

// Define a dependency
public protocol NetworkDependencies {
    func networker() -> any Networking
}

// Provide a known default where we can
extension NetworkDependencies {
    public func networker() -> any Networking {
        Networker()
    }
}

// Define a dependency
public protocol LoggingDependencies {
    func logger() -> any Logging
}

// Provide a known default where we can
extension LoggingDependencies {
    public func logger() -> any Logging {
        Logger()
    }
}

// Define a dependency
public protocol AnalyticsDependencies {
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
public protocol MockCoreDependencies: CoreDependencies {}

// Provide mock types
extension MockCoreDependencies {
    // override default provider
    public func networker() -> any Networking {
        MockNetworker()
    }
    // provide missing service
    public func analytics() -> any AnalyticsService {
        MockAnalyticsService()
    }
}

// Make our mock resolver
public struct MockCoreResolver: MockCoreDependencies {}

// Make our environment entry
extension EnvironmentValues {
    @Entry public var coreDependencies: CoreDependencies = MockCoreResolver()
}
