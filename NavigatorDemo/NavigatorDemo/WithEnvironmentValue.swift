//
//  WithEnvironmentValue.swift
//  NavigatorDemo
//
//  Created by Michael Long on 12/22/24.
//
//  Idle musings of a demented mind
//

import SwiftUI

struct WithEnvironmentValue<T, Content: View>: View {
    private let path: WritableKeyPath<EnvironmentValues, T>
    private let content: (T) -> Content
    @Environment(\.self) private var values // Access all EnvironmentValues
    init(_ path: WritableKeyPath<EnvironmentValues, T>, @ViewBuilder content: @escaping (T) -> Content) {
        self.path = path
        self.content = content
    }
    var body: some View {
        content(values[keyPath: path])
    }
}

//protocol DependentObject {
//    associatedtype Dependency
//    var dependency: Dependency { get set }
//}
//
//@MainActor
//@propertyWrapper
//struct EnvironmentDependentStateObject<D, T: ObservableObject & DependentObject & AnyObject>: DynamicProperty
//where D == T.Dependency {
//    private let keyPath: WritableKeyPath<EnvironmentValues, D>
//    @StateObject private var object: T
//    @Environment(\.self) private var values
//    init(_ keyPath: WritableKeyPath<EnvironmentValues, D>, _ thunk: @autoclosure @escaping () -> T) {
//        self.keyPath = keyPath
//        self._object = .init(wrappedValue: thunk())
//    }
//    var wrappedValue: T {
//        var object = object
//        object.dependency = values[keyPath: keyPath]
//        return object
//    }
//}
