//
//  NavigationSend.swift
//  Navigator
//
//  Created by Michael Long on 11/14/24.
//

import Combine
import SwiftUI

extension Navigator {

    @MainActor
    public func send(_ value: any Hashable) {
        print("Navigator \(id) sending \(value)")
        publisher.send((value, []))
    }

    @MainActor
    public func send(values: [any Hashable]) {
        guard let value: any Hashable = values.first else {
            return
        }
        print("Navigator \(id) sending \(value)")
        publisher.send((value, Array(values.dropFirst())))
    }

}

public typealias NavigationSendValues = (value: any Hashable, values: [any Hashable])
public typealias NavigationReceiveHandler<T> = (_ value: T, _ navigator: Navigator) -> NavigationReceiveResumeType
public typealias NavigationReceiveValueHandler<T> = (_ value: T) -> NavigationReceiveResumeType

public enum NavigationReceiveResumeType {
    case auto
    case immediately
    case after(TimeInterval)
    case with([AnyHashable])
    case cancel
}

extension View {
    public func onNavigationReceive<T: Hashable>(handler: @escaping NavigationReceiveHandler<T>) -> some View {
        self.modifier(OnNavigationReceiveModifier(handler: handler))
    }

    public func onNavigationReceive<T: Hashable>(handler: @escaping NavigationReceiveValueHandler<T>) -> some View {
        self.modifier(OnNavigationReceiveModifier(handler: { (value, _) in handler(value) }))
    }

    public func onNavigationReceive<T: NavigationDestinations>(_ type: T.Type) -> some View {
        self.modifier(OnNavigationReceiveModifier<T> { (value, navigator) in
            navigator.navigate(to: value)
            return .auto
        })
    }
}

private struct OnNavigationReceiveModifier<T: Hashable>: ViewModifier {

    private let handler: NavigationReceiveHandler<T>

    @Environment(\.navigator) var navigator: Navigator

    init(handler: @escaping NavigationReceiveHandler<T>) {
        self.handler = handler
    }

    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { (value, values) in
                print("Navigator \(navigator.id) receiving \(value)")
                resume(handler(value, navigator), values: values)
            }
    }

    var publisher: AnyPublisher<(T, [any Hashable]), Never> {
        navigator.publisher
            .compactMap { $0 as? (T, [any Hashable]) }
            .eraseToAnyPublisher()
    }

    func resume(_ action: NavigationReceiveResumeType, values: [any Hashable], delay: TimeInterval = 0.7) {
        guard !values.isEmpty else { return }
        switch action {
        case .auto:
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                navigator.send(values: values)
            }
        case .immediately:
            navigator.send(values: values)
        case .after(let interval):
            resume(.auto, values: values, delay: interval)
        case .with(let newValues):
            resume(.auto, values: newValues)
        case .cancel:
            break
        }
    }

}
