//
//  NavigationAction.swift
//  Navigator
//
//  Created by Michael Long on 1/10/25.
//

import SwiftUI

extension Navigator {

    @MainActor
    public func perform(_ action: NavigationAction) {
        send(action, [])
    }

    @MainActor
    public func perform(actions: [NavigationAction]) {
        guard let value: any Hashable = actions.first else {
            return
        }
        send(value, Array(actions.dropFirst()))
    }

}

public struct NavigationAction: Hashable {

    public let name: String

    private let action: (Navigator) -> NavigationReceiveResumeType

    public init(_ name: String = #function, action: @escaping (Navigator) -> NavigationReceiveResumeType) {
        self.name = name
        self.action = action
    }

    public func callAsFunction(_ navigator: Navigator) -> NavigationReceiveResumeType {
        action(navigator)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    public static func == (lhs: NavigationAction, rhs: NavigationAction) -> Bool {
        lhs.name == rhs.name
    }

}

extension NavigationAction {

    @MainActor public static var cancel: NavigationAction {
        .init { _ in .cancel }
    }

    @MainActor public static var dismissAll: NavigationAction {
        .init {
            do {
                return try $0.dismissAll() ? .auto : .immediately
            } catch {
                return .cancel
            }
        }
    }

    @MainActor public static var empty: NavigationAction {
        .init { _ in .immediately }
    }

    @MainActor public static func popAll(in name: String) -> NavigationAction {
        .init { navigtor in
            if let found = navigtor.named(name) {
                return found.popAll() ? .auto : .immediately
            }
            return .cancel
        }
    }

    @MainActor public static func send(_ value: any Hashable) -> NavigationAction {
        .init {
            $0.send(value)
            return .immediately
        }
    }

    @MainActor public static func with(_ name: String, perform: @escaping (Navigator) -> Void) -> NavigationAction {
        .init { navigtor in
            if let found = navigtor.named(name) {
                perform(found)
                return .auto
            }
            return .cancel
        }
    }

}
