//
//  AnalyticsService.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/30/25.
//

import Foundation

public protocol AnalyticsService {
    func event(_ event: String)
}

public class MockAnalyticsService: AnalyticsService {
    public var events: [String] = []
    public func event(_ event: String) {
        events.append(event)
        print(event)
    }
}

public class ThirdPartyAnalyticsService: AnalyticsService {
    public func event(_ event: String) {
        print(event)
    }
}
