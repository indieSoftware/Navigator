//
//  Networking.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/30/25.
//

import Foundation

public protocol Networking {
    func load<T>() -> T?
}

public struct Networker: Networking {
    public func load<T>() -> T? {
        // demo only returns strings
        "(A)" as? T
    }
}

public class MockNetworker: Networking, @unchecked Sendable {

    public init() {}

    public func load<T>() -> T? {
        lock.withLock {
            let id = ObjectIdentifier(T.self)
            if let factory = factories[id] as? () -> T {
                return factory()
            }
            return nil
        }
    }

    public func add<T>(_ factory: @escaping () -> T) {
        lock.withLock {
            let id = ObjectIdentifier(T.self)
            factories[id] = factory
        }
    }

    public func reset() {
        lock.withLock {
            factories.removeAll()
        }
    }

    private var lock: NSRecursiveLock = .init()
    private var factories: [ObjectIdentifier: Any] = [:]
    
}
