//
//  NavigationAction.swift
//  Navigator
//
//  Created by Michael Long on 1/10/25.
//

import SwiftUI

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
        .init { $0.dismissAll() ? .auto : .immediately }
    }

}
