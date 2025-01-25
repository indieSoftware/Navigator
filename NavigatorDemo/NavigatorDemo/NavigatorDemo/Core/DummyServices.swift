//
//  DummyServices.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/24/25.
//

import Foundation

//
// MISCELLANEOUS SERVICE PROTOCOLS AND MOCKS
//

public protocol Networking {
    func load<T>() -> T?
}

public struct Networker: Networking {
    public func load<T>() -> T? {
        // demo only returns strings
        "(A)" as? T
    }
}

public class MockNetworker: Networking {
    // Extremely simple way to expose a single factory for testing
    public nonisolated(unsafe) static var factory: Any = { "(M)" }
    public func load<T>() -> T? {
        if let factory = Self.factory as? () -> T {
            return factory()
        }
        return nil
    }
}

extension MockCoreDependencies {
    public func mock<T>(_ factory: @escaping () -> T) -> Self {
        MockNetworker.factory = factory
        return self
    }
}

public protocol Loading {
    func load() -> String
}

public struct Loader: Loading {
    let networker: Networking
    public func load() -> String {
        networker.load() ?? "?"
    }
}

public protocol AnalyticsService {
    func event(_ event: String)
}

public class ThirdPartyAnalyticsService: AnalyticsService {
    public func event(_ event: String) {
        print(event)
    }
}

public struct MockAnalyticsService: AnalyticsService {
    public func event(_ event: String) {
        print(event)
    }
}

public protocol Logging {
    func log(_ message: String)
}

public struct Logger: Logging {
    public func log(_ message: String) {
        print(message)
    }
}

public protocol SettingsProviding {
    func settings() -> [String]
}

public struct SettingsProvider: SettingsProviding {
    public func settings() -> [String] {
        []
    }
}

