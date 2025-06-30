//
//  AnalyticsService.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/30/25.
//

import Foundation

public protocol AnalyticsService {
    func initialize() async throws
    func event(_ event: String)
}

public class MockAnalyticsService: AnalyticsService {
    public var events: [String] = []
    @MainActor public func initialize() async throws {
        print("MockAnalyticsService Initialized")
    }
    public func event(_ event: String) {
        events.append(event)
        print(event)
    }
}

public nonisolated class ThirdPartyAnalyticsService: AnalyticsService {
    private var initializationNeeded = true
    public nonisolated func initialize() async throws {
        guard initializationNeeded else { return }
        try await Task.sleep(nanoseconds: 200)
        print("ThirdPartyAnalyticsService Initialized")
        initializationNeeded = false
    }
    public func event(_ event: String) {
        print(event)
    }
}
