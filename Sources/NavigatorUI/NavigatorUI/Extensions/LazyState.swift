//
//  LazyState.swift
//  Runes
//
//  Created by Michael Long on 3/5/25.
//

import Observation
import SwiftUI

/// A property wrapper that lazily creates an `Observable` value on first access.
///
/// `LazyState` is useful when you want to delay the construction of an
/// expensive `@Observable` object until it is actually needed by the view.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
@MainActor
@propertyWrapper
public struct LazyState<T: Observable>: DynamicProperty {

    @State private var thunkedValue: ThunkedValue

    /// Creates a new lazy state wrapper from the given thunk.
    ///
    /// The thunk is stored and only evaluated the first time the wrapped
    /// value is read.
    ///
    /// - Parameter thunk: A closure that constructs the observable value.
    public init(wrappedValue thunk: @autoclosure @escaping () -> T) {
        _thunkedValue = State(wrappedValue: ThunkedValue(wrappedValue: thunk))
    }

    /// The lazily-created observable value.
    public var wrappedValue: T {
        thunkedValue.value
    }

    /// A binding that exposes the lazily-created value.
    ///
    /// The setter is intentionally ignored to prevent replacing the
    /// underlying observable instance.
    public var projectedValue: Binding<T> {
        Binding(get: { thunkedValue.value }, set: { _ in })
    }

    private final class ThunkedValue {

        private var object: T!
        private var thunk: (() -> T)?

        init(wrappedValue thunk: @escaping () -> T) {
            self.thunk = thunk
        }

        var value: T {
            if let thunk {
                object = thunk()
                self.thunk = nil
            }
            return object
        }

    }

}
