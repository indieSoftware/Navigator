//
//  Dependencies.swift
//  NavigatorDemo
//
//  Created by Michael Long on 12/5/24.
//

import Navigator
import SwiftUI

//
// CORE MODULE DEPENDENCIES
//

// Convenience type specifies everything visible and available in our core module
public protocol CoreDependencies: NetworkDependencies
    & LoggingDependencies
    & AnalyticsDependencies
    & DependencyCaching
{}

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
        cached { MockNetworker() as any Networking }
    }
    // provide missing service
    public func analytics() -> any AnalyticsService {
        cached { MockAnalyticsService() as any AnalyticsService }
    }
    #if DEBUG
    // add preview and mocking support for networking
    public func mock<T>(_ factory: @escaping () -> T) -> Self {
        (networker() as? MockNetworker)?.add(factory)
        return self
    }
    #endif
}

// Make our mock resolver. Default implementation provides the dependency cache so that subclasses aren't required to do so.
public class MockCoreResolver: MockCoreDependencies {
    public let cache: DependencyCache = .init()
}

// Make our environment entry
extension EnvironmentValues {
    @Entry public var coreDependencies: CoreDependencies = MockCoreResolver()
}
