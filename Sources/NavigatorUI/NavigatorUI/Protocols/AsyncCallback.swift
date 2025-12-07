//
//  AsyncCallback.swift
//  Navigator
//
//  Created by Michael Long on 12/2/25.
//

import SwiftUI

// Allows async throwing callback handlers to be passed in NavigationDestination types as a Hashable type based on its name.
//
// Note, however, that AsyncCallback handlers are NOT Codable and as such will disable state restoration in any ManagedNavigationStack that uses them.
//
// Using callback handlers between views will also interfere with deep linking, since URL handlers and other deep linking mechanisms will probably
// be unable to synthesize the correct callback closures externally.
//
// Consider navigation Send or Checkpoints with values instead.
public struct AsyncCallback<Value>: Hashable, Equatable {

    public let identifier: String
    public let handler: (Value) async throws -> Void

    public init(_ identifier: String = UUID().uuidString, handler: @escaping (Value) async throws -> Void) {
        self.identifier = identifier
        self.handler = handler
    }

    public func callAsFunction(_ value: Value) async throws {
        try await handler(value)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public static func == (lhs: AsyncCallback<Value>, rhs: AsyncCallback<Value>) -> Bool {
        lhs.identifier == rhs.identifier
    }

}
