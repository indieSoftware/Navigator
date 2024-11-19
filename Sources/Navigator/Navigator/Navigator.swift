//
//  Navigator.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import Combine
import SwiftUI

public enum NavigationMethod {
    case push
    case sheet
    case fullScreenCover
    case send
}

public class Navigator: ObservableObject {

    @Published internal var path: NavigationPath = .init()
    @Published internal var sheet: AnyNavigationDestination? = nil
    @Published internal var fullScreenCover: AnyNavigationDestination? = nil

    internal var id: UUID = .init()
    
    internal weak var parent: Navigator?
    internal var children: [UUID : WeakNavigator] = [:]

    internal var dismissible: Dismissible? = nil

    internal var publisher: PassthroughSubject<any Hashable, Never>

    public init(parent: Navigator? = nil) {
        if let parent {
            self.parent = parent
            self.publisher = parent.publisher
            parent.addChild(self)
            print("Navigator init: \(id) parent \(parent.id)")
        } else {
            self.parent = nil
            self.publisher = .init()
            print("Navigator init: \(id)")
        }
     }

    deinit {
        print("Navigator deinit: \(id)")
        parent?.removeChild(self)
    }

    public var root: Navigator {
        parent?.root ?? self
    }

    internal func addChild(_ child: Navigator) {
        children[child.id] = WeakNavigator(navigator: child)
    }

    internal func removeChild(_ child: Navigator) {
        children.removeValue(forKey: child.id)
    }

    internal struct AnyNavigationDestination: Identifiable {
        public let destination: any NavigationDestinations
        public var id: Int { destination.id }
        @MainActor public var asView: AnyView { destination.asView }
    }

    internal struct WeakNavigator {
        weak var navigator: Navigator?
    }

}

extension Navigator {

    @MainActor
    public func navigate(to destination: any NavigationDestinations) {
        navigate(to: destination, via: destination.method)
    }

    @MainActor
    public func navigate(to destination: any NavigationDestinations, via method: NavigationMethod) {
        switch method {
        case .push:
            push(destination)
        case .sheet:
            sheet = AnyNavigationDestination(destination: destination)
        case .fullScreenCover:
            fullScreenCover = AnyNavigationDestination(destination: destination)
        case .send:
            send(destination)
        }
    }

}

extension Navigator {

    @MainActor
    public func push(_ page: any NavigationDestinations) {
        path.append(page)
    }

    @MainActor
    public func pop() {
        if !isEmpty {
            path.removeLast()
        }
    }

    @MainActor
    public func popAll() {
        if !isEmpty {
            path.removeLast(path.count)
        }
    }

    @MainActor
    public var isEmpty: Bool {
        path.isEmpty
    }

}

extension Navigator {

    @MainActor
    @discardableResult
    public func dismiss() -> Bool {
        var dismissed = false
        if isPresented {
            parent?.dismissible?.dismiss()
            parent?.dismissible = nil
            dismissed = true
        }
        for child in children.values {
            if let navigator = child.navigator, navigator.dismiss() {
                dismissed = true
            }
        }
        return dismissed
    }

    @MainActor
    @discardableResult
    public func dismissAll() -> Bool {
        root.dismiss()
    }

    public nonisolated var isPresented: Bool {
        parent?.dismissible?.navigator != nil
    }

    public nonisolated var isPresenting: Bool {
        dismissible?.navigator != nil
    }

    internal func setDismissAction(_ action: DismissAction) {
        guard !isPresented else {
            return
        }
        parent?.dismissible = .init(navigator: self, dismiss: action)
    }

    internal class Dismissible {
        internal init(navigator: Navigator?, dismiss: DismissAction) {
            self.navigator = navigator
            self.dismiss = dismiss
        }
        weak var navigator: Navigator?
        let dismiss: DismissAction
    }

}

extension EnvironmentValues {
    @Entry public var navigator: Navigator = Navigator.root
}

extension Navigator {
    nonisolated(unsafe) internal static let root: Navigator = Navigator()
}
