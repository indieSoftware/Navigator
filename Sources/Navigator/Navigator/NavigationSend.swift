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
        log("Navigator \(id) sending \(value)")
        publisher.send((value, []))
    }

    @MainActor
    public func send(values: [any Hashable]) {
        guard let value: any Hashable = values.first else {
            return
        }
        log("Navigator \(id) sending \(value)")
        publisher.send((value, Array(values.dropFirst())))
    }

}

public typealias NavigationSendValues = (value: any Hashable, values: [any Hashable])
public typealias NavigationSendHandler<T> = (_ value: T, _ navigator: Navigator) -> NavigationSendResumeType
public typealias NavigationSendValueOnlyHandler<T> = (_ value: T) -> NavigationSendResumeType

public enum NavigationSendResumeType {
    case auto
    case immediately
    case after(TimeInterval)
    case with([AnyHashable])
    case cancel
}

extension View {
    public func onNavigationSend<T: Hashable>(handler: @escaping NavigationSendHandler<T>) -> some View {
        self.modifier(OnNavigationSendModifier(handler: handler))
    }

    public func onNavigationSend<T: Hashable>(handler: @escaping NavigationSendValueOnlyHandler<T>) -> some View {
        self.modifier(OnNavigationSendModifier(handler: { (value, _) in handler(value) }))
    }

    public func onNavigationSend<T: NavigationDestination>(_ type: T.Type) -> some View {
        self.modifier(OnNavigationSendModifier<T> { (value, navigator) in
            navigator.navigate(to: value)
            return .auto
        })
    }
}

private struct OnNavigationSendModifier<T: Hashable>: ViewModifier {

    private let handler: NavigationSendHandler<T>

    @Environment(\.navigator) var navigator: Navigator

    init(handler: @escaping NavigationSendHandler<T>) {
        self.handler = handler
    }

    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { (value, values) in
                navigator.log("Navigator \(navigator.id) receiving \(value)")
                resume(handler(value, navigator), values: values)
            }
    }

    var publisher: AnyPublisher<(T, [any Hashable]), Never> {
        navigator.publisher
            .compactMap { $0 as? (T, [any Hashable]) }
            .eraseToAnyPublisher()
    }

    func resume(_ action: NavigationSendResumeType, values: [any Hashable], delay: TimeInterval = 0.7) {
        guard !values.isEmpty else {
            return
        }
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
