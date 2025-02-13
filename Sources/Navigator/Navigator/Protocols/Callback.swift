//
//  Callback.swift
//  Navigator
//
//  Created by Michael Long on 2/12/25.
//

import SwiftUI

// Allows callback handlers to be passed in NavigationDestination types as a Hashable type based on its name.
//
// Note, however, that Callback handlers are NOT Codable and as such will disable state restoration in any ManagedNavigationStack that uses them.
//
// Using callback handlers between views will also interfere with deep linking, since URL handlers and other deep linking mechanisms will probably
// be unable to synthesize the correct binding.
//
// Consider navigation Send or Checkpoints with values instead.
public struct Callback<Value>: Hashable, Equatable {

    public let name: String
    public let handler: (Value) -> Void

    public init(_ name: String, handler: @escaping (Value) -> Void) {
        self.name = name
        self.handler = handler
    }

    public func callAsFunction(_ value: Value) {
        handler(value)
    }

    public func hash(into hasher: inout Hasher) {
       hasher.combine(name)
    }

    public static func == (lhs: Callback<Value>, rhs: Callback<Value>) -> Bool {
        lhs.name == rhs.name
    }

}
