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
        send(value, [])
    }

    @MainActor
    public func send(values: [any Hashable]) {
        guard let value: any Hashable = values.first else {
            return
        }
        send(value, Array(values.dropFirst()))
    }

    internal func send(_ value: any Hashable, _ values: [any Hashable]) {
        log("Navigator \(id) sending \(value)")
        let values = NavigationSendValues(value: value, values: values, sender: self)
        publisher.send(values)
    }

}

extension View {

    public func navigationSend<T: Hashable & Equatable>(_ item: Binding<T?>) -> some View {
        self.modifier(NavigationSendValueModifier<T>(item: item))
    }

    public func navigationSend<T: Hashable & Equatable>(values: Binding<[T]?>) -> some View {
        self.modifier(NavigationSendValuesModifier<T>(values: values))
    }

}

public typealias NavigationReceiveResumeHandler<T> = (_ value: T, _ navigator: Navigator) -> NavigationReceiveResumeType
public typealias NavigationReceiveResumeValueOnlyHandler<T> = (_ value: T) -> NavigationReceiveResumeType

public enum NavigationReceiveResumeType {
    case auto
    case immediately
    case after(TimeInterval)
    case with([any Hashable])
    case checkpoint(NavigationCheckpoint)
    case cancel
}

extension View {

    public func onNavigationReceive<T: Hashable>(handler: @escaping NavigationReceiveResumeHandler<T>) -> some View {
        self.modifier(OnNavigationReceiveModifier(handler: handler))
    }

    public func onNavigationReceive<T: Hashable>(handler: @escaping NavigationReceiveResumeValueOnlyHandler<T>) -> some View {
        self.modifier(OnNavigationReceiveModifier(handler: { (value, _) in handler(value) }))
    }

    public func onNavigationReceive<T: NavigationDestination>(_ type: T.Type) -> some View {
        self.modifier(OnNavigationReceiveModifier<T> { (value, navigator) in
            navigator.navigate(to: value)
            return .auto
        })
    }

}

private struct NavigationSendValueModifier<T: Hashable & Equatable>: ViewModifier {
    @Binding internal var item: T?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: item) { item in
                if let item {
                    navigator.send(item)
                    self.item = nil
                }
            }
    }
}

private struct NavigationSendValuesModifier<T: Hashable & Equatable>: ViewModifier {
    @Binding internal var values: [T]?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: values) { values in
                if let values {
                    navigator.send(values: values)
                    self.values = nil
                }
            }
    }
}

private struct OnNavigationReceiveModifier<T: Hashable>: ViewModifier {

    private let handler: NavigationReceiveResumeHandler<T>

    @Environment(\.navigator) var navigator: Navigator

    init(handler: @escaping NavigationReceiveResumeHandler<T>) {
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
            .compactMap { published in
                if let value = published.value as? T {
                    #if DEBUG
                    guard published.consumable() else {
                        return nil
                    }
                    #endif
                    return (value, published.values)
                }
                return nil
            }
            .eraseToAnyPublisher()
    }

    func resume(_ action: NavigationReceiveResumeType, values: [any Hashable], delay: TimeInterval = 0.7) {
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
        case .checkpoint(let checkpoint):
            navigator.returnToCheckpoint(checkpoint)
        case .cancel:
            break
        }
    }

}

#if DEBUG
internal class NavigationSendValues {
    let value: any Hashable
    let values: [any Hashable]
    let sender: Navigator
    let type: String
    var consumed: Bool = false
    internal init<T: Hashable>(value: T, values: [any Hashable], sender: Navigator) {
        self.value = value
        self.values = values
        self.sender = sender
        self.type = String(describing: T.self)
    }
    deinit {
        if !consumed {
            sender.log(type: .warning, "Navigator missing receive handler for type: \(type)!!!")
        }
    }
    func consumable() -> Bool {
        guard !consumed else {
            sender.log(type: .warning, "Navigator additional receive handlers ignored for type: \(type)!!!")
            return false
        }
        consumed.toggle()
        return true
    }
}
#else
internal struct NavigationSendValues {
    let value: any Hashable
    let values: [any Hashable]
    let sender: Navigator
}
#endif
