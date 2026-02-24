//
//  AsyncCallback.swift
//  Navigator
//
//  Created by Michael Long on 12/2/25.
//

import SwiftUI

/// Allows async throwing callback handlers to be passed in
/// ``NavigationDestination`` types as a hashable value based on an identifier.
///
/// > Warning: `AsyncCallback` handlers are **not** `Codable` and will disable
/// > state restoration in any ``ManagedNavigationStack`` that uses them.
/// >
/// > Using callbacks between views can also interfere with deep linking,
/// > since URL handlers and other deep-link mechanisms cannot synthesize
/// > the underlying closures.
///
/// In many cases, using navigation send or checkpoints with values will
/// produce a more robust design.
public struct AsyncCallback<Value>: Hashable, Equatable {

    /// A stable identifier used for hashing and equality.
    public let identifier: String

    /// The underlying async throwing callback closure.
    public let handler: (Value) async throws -> Void

    /// Creates a new async callback with an optional identifier.
    ///
    /// - Parameters:
    ///   - identifier: An optional identifier for this callback. Defaults
    ///     to a freshly generated UUID string.
    ///   - handler: The async closure to invoke when the callback is called.
    public init(_ identifier: String = UUID().uuidString, handler: @escaping (Value) async throws -> Void) {
        self.identifier = identifier
        self.handler = handler
    }

    /// Invokes the underlying handler.
    ///
    /// - Parameter value: The value to pass to the handler.
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
