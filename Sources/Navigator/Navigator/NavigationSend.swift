//
//  NavigationSend.swift
//  Navigator
//
//  Created by Michael Long on 11/14/24.
//

import Combine
import SwiftUI

extension Navigator {

    public func send(_ value: any Hashable) {
        print("Navigator \(id) sending \(value)")
        Navigator.values = []
        publisher.send(value)
    }

    public func send(values: [any Hashable]) {
        guard let value: any Hashable = values.first else {
            return
        }
        print("Navigator \(id) sending \(value)")
        Navigator.values = Array(values.dropFirst())
        publisher.send(value)
    }

}

public enum NavigationReceiveResumeType {
    case auto
    case immediately
    case after(TimeInterval)
    case with([AnyHashable])
    case cancel
}

public typealias NavigationReceiveResumeHandler = (NavigationReceiveResumeType) -> Void

extension View {
    public func onNavigationReceive<T: Hashable>(handler: @escaping (Navigator, T) -> Void) -> some View {
        self.modifier(OnNavigationReceiveModifier(handler: handler))
    }

    public func onNavigationReceive<T: NavigationDestinations>(_ type: T.Type) -> some View {
        self.modifier(OnNavigationReceiveModifier<T> { (navigator, value) in
            navigator.navigate(to: value)
            navigator.resume()
        })
    }
}

extension Navigator {

    @MainActor
    public func resume(_ action: NavigationReceiveResumeType = .auto, delay: TimeInterval = 0.7) {
        switch action {
        case .auto:
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.send(values: Navigator.values)
            }
        case .immediately:
            self.send(values: Navigator.values)
        case .after(let interval):
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                self.send(values: Navigator.values)
            }
        case .with(let newValues):
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.send(values: newValues)
            }
        case .cancel:
            Navigator.values = []
        }
    }

    nonisolated(unsafe) internal static var values: [any Hashable] = []

}

private struct OnNavigationReceiveModifier<T: Hashable>: ViewModifier {

    private let handler: (_ navigator: Navigator, _ value: T) -> Void

    @Environment(\.navigator) var navigator: Navigator

    init(handler: @escaping (_ navigator: Navigator, _ value: T) -> Void) {
        self.handler = handler
    }

    func body(content: Content) -> some View {
        content
            .onReceive(publisher) { value in
                print("Navigator \(navigator.id) receiving \(value)")
                handler(navigator, value)
            }
    }

    var publisher: AnyPublisher<T, Never> {
        navigator.publisher
            .compactMap { $0 as? T }
            .eraseToAnyPublisher()
    }

}
