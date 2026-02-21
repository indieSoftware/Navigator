//
//  LazyState.swift
//  Runes
//
//  Created by Michael Long on 3/5/25.
//

import Observation
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
@MainActor
@propertyWrapper
public struct LazyState<T: Observable>: DynamicProperty {

    @State private var thunkedValue: ThunkedValue

    public init(wrappedValue thunk: @autoclosure @escaping () -> T) {
        _thunkedValue = State(wrappedValue: ThunkedValue(wrappedValue: thunk))
    }

    public var wrappedValue: T {
        thunkedValue.value
    }

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
