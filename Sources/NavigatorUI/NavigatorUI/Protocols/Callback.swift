//
//  Callback.swift
//  Navigator
//
//  Created by Michael Long on 2/12/25.
//

import SwiftUI

/// Allows callback handlers to be passed in ``NavigationDestination`` types
/// as a hashable value based on an identifier.
///
/// ```swift
/// enum FormDestinations: NavigationDestination {
///     case edit(Item, onSave: Callback<Item>)
///
///     var body: some View {
///         switch self {
///         case .edit(let item, let onSave):
///             EditView(item: item) { updated in
///                 onSave(updated)
///             }
///         }
///     }
/// }
/// ```
///
/// > Warning: `Callback` handlers are **not** `Codable` and will disable
/// > state restoration in any ``ManagedNavigationStack`` that uses them.
/// >
/// > Using callbacks between views can also interfere with deep linking,
/// > since URL handlers and other deep-link mechanisms cannot synthesize
/// > the underlying closures.
///
/// In many cases, using navigation send or checkpoints with values will
/// produce a more robust design.
public struct Callback<Value>: Hashable, Equatable {

    /// A stable identifier used for hashing and equality.
    public let identifier: String

    /// The underlying callback closure.
    public let handler: (Value) -> Void

    /// Creates a new callback with an optional identifier.
    ///
    /// - Parameters:
    ///   - identifier: An optional identifier for this callback. Defaults
    ///     to a freshly generated UUID string.
    ///   - handler: The closure to invoke when the callback is called.
    public init(_ identifier: String = UUID().uuidString, handler: @escaping (Value) -> Void) {
        self.identifier = identifier
        self.handler = handler
    }

    /// Invokes the underlying handler.
    ///
    /// - Parameter value: The value to pass to the handler.
    public func callAsFunction(_ value: Value) {
        handler(value)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public static func == (lhs: Callback<Value>, rhs: Callback<Value>) -> Bool {
        lhs.identifier == rhs.identifier
    }

}
