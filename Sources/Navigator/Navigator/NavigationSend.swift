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
    @inlinable public func send(value: any Hashable) {
        send(values: [value])
    }

    @MainActor
    public func send(values: [any Hashable]) {
        guard let value: any Hashable = values.first else {
            return
        }
        let remainingValues = Array(values.dropFirst())
        if let action = value as? NavigationAction {
            log("Navigator \(id) executing action \(action.name)")
            resume(action(self), values: remainingValues)
        } else {
            log("Navigator \(id) sending \(value)")
            state.publisher.send(NavigationSendValues(navigator: root, value: value, values: remainingValues))
        }
    }

    @MainActor
    internal func resume(_ action: NavigationReceiveResumeType, values: [any Hashable] = [], delay: TimeInterval? = nil) {
        switch action {
        case .auto:
            let delay: TimeInterval = delay ?? state.animationSpeed
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.send(values: values)
            }
        case .immediately:
            send(values: values)
        case .after(let interval):
            resume(.auto, values: values, delay: interval)
        case .with(let newValues):
            resume(.immediately, values: newValues)
        case .inserting(let newValues):
            resume(.immediately, values: newValues + values)
        case .appending(let newValues):
            resume(.immediately, values: values + newValues)
        case .checkpoint(let checkpoint):
            returnToCheckpoint(checkpoint)
        case .pause:
            Navigator.resumableValues = values
        case .cancel:
            break
        }
    }

    /// Resumes sending any values paused by an onNavigationReceive handler.
    ///
    /// This allows for actions like authentication sequences to occur as part of a deep linking sequence. The onNavigationReceive
    /// handler pauses the sequence, and this function resumes them.
    @MainActor
    public func resume(condition: Bool = true) {
        guard condition, let values = Navigator.resumableValues else {
            return
        }
        send(values: values)
    }

    @MainActor
    public func cancelResume() {
        Navigator.resumableValues = nil
    }

    @MainActor internal static var resumableValues: [any Hashable]? = nil

}

extension View {

    public func navigationSend<T: Hashable & Equatable>(_ item: Binding<T?>) -> some View {
        self.modifier(NavigationSendValueModifier<T>(item: item))
    }

    public func navigationSend<T: Hashable & Equatable>(values: Binding<[T]?>) -> some View {
        self.modifier(NavigationSendValuesModifier<T>(values: values))
    }

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

public typealias NavigationReceiveResumeHandler<T> = (_ value: T, _ navigator: Navigator) -> NavigationReceiveResumeType
public typealias NavigationReceiveResumeValueOnlyHandler<T> = (_ value: T) -> NavigationReceiveResumeType

public enum NavigationReceiveResumeType {
    /// Automatically resumes sending remaining values after a brief delay
    case auto
    /// Resumes sending remaining values immediately, without delay
    case immediately
    /// Automatically resumes sending remaining values after a specified delay
    case after(TimeInterval)
    ///  Resumes sending new values after a brief delay
    case with([any Hashable])
    ///  Inserts new values into the queue
    case inserting([any Hashable])
    ///  Appends new values onto the queue
    case appending([any Hashable])
    /// Indicates we should return to a named checkpoint (normally used internally)
    case checkpoint(NavigationCheckpoint)
    /// Indicates that any remaining deep linking values should be saved for later resumption
    case pause
    /// Cancels any remaining values in the send queue
    case cancel
}

private struct NavigationSendValueModifier<T: Hashable & Equatable>: ViewModifier {
    @Binding internal var item: T?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: item) { item in
                if let item {
                    navigator.send(value: item)
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
            .onReceive(navigator.state.publisher) { values in
                if let value: T = values.consume() {
                    navigator.log("Navigator \(navigator.id) receiving \(value)")
                    values.resume(handler(value, navigator))
                }
            }
    }

}

internal class NavigationSendValues {

    internal let navigator: Navigator
    internal let value: any Hashable
    internal let values: [any Hashable]
    internal let identifier: String?

    internal var consumed: Bool = false

    internal init(navigator: Navigator, value: any Hashable, values: [any Hashable], identifier: String? = nil) {
        self.navigator = navigator
        self.value = value
        self.values = values
        self.identifier = identifier
    }

    deinit {
        if consumed == false {
            if let identifier {
                navigator.log("Navigator missing receive handler: \(identifier) for type: \(type(of: value))!!!")
            } else {
                navigator.log("Navigator missing receive handler for type: \(type(of: value))!!!")
            }
        }
    }

    @MainActor
    internal func consume<T>(_ identifier: String? = nil) -> T? {
        if let value = value as? T, self.identifier == identifier {
            if consumed {
                navigator.log("Navigator additional receive handlers ignored for type: \(type(of: value))!!!")
                return nil
            }
            consumed.toggle()
            return value
        }
        return nil
    }

    @MainActor
    internal func resume(_ resume: NavigationReceiveResumeType) {
        navigator.resume(resume, values: values)
    }

}

extension NavigationSendValues {

    convenience init<T: Hashable>(navigator: Navigator, checkpoint: NavigationCheckpoint, value: T) {
        self.init(navigator: navigator, value: value, values: [], identifier: checkpoint.name)
    }

}
