//
//  Binding+Extension.swift
//  Navigator
//
//  Created by Michael Long on 2/12/25.
//

import SwiftUI

/// Allows bindings to be passed in ``NavigationDestination`` types as
/// hashable values when the bound type is also `Hashable`.
///
/// > Warning: `Binding` values are **not** `Codable` and will disable
/// > state restoration in any ``ManagedNavigationStack`` that uses them.
/// >
/// > Bindings between views can also interfere with deep linking, since
/// > URL handlers and other deep-link mechanisms cannot synthesize the
/// > underlying binding.
///
/// In many cases, using navigation send or checkpoints with values will
/// produce a more robust design.
extension Binding: @retroactive Hashable, @retroactive Equatable where Value: Hashable {

    /// Hashes the binding based on its current wrapped value.
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }

    /// Two bindings are considered equal when their wrapped values have
    /// the same hash value.
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue.hashValue == rhs.wrappedValue.hashValue
    }

}
