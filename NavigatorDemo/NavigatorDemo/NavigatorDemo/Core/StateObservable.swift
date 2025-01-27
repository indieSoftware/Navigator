//
//  StateObservable.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/27/25.
//

import Observation
import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *)
@MainActor
@propertyWrapper
public struct StateObservable<T>: DynamicProperty where T: Observable & AnyObject {

    @StateObject private var wrappedObject: WrappedObject

    public init(wrappedValue thunk: @autoclosure @escaping () -> T) {
        self._wrappedObject = StateObject(wrappedValue: WrappedObject(object: thunk()))
    }

    public var wrappedValue: T {
        get {
            wrappedObject.object
        }
        nonmutating set {
            wrappedObject.object = newValue
        }
    }

    public var projectedValue: Bindable<T> {
        get {
            Bindable(wrappedObject.object)
        }
    }

    internal class WrappedObject: ObservableObject {
        @Published var object: T
        init(object: T) {
            self.object = object
        }
    }

}
