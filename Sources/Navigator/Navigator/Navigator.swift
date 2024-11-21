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

    @Published internal var path: NavigationPath = .init() {
        didSet {
            cleanCheckpoints()
        }
    }

    @Published internal var sheet: AnyNavigationDestination? = nil
    @Published internal var fullScreenCover: AnyNavigationDestination? = nil

    internal var id: UUID = .init()
    
    internal weak var parent: Navigator?
    internal var children: [UUID : WeakObject<Navigator>] = [:]

    internal var dismissible: DismissAction? = nil

    internal var checkpoints: [String: WeakObject<NavigationCheckpoint>] = [:]

    internal var publisher: PassthroughSubject<NavigationSendValues, Never>

    public init(parent: Navigator? = nil, action: DismissAction? = nil) {
        self.dismissible = action
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
        children[child.id] = WeakObject(child)
    }

    internal func removeChild(_ child: Navigator) {
        children.removeValue(forKey: child.id)
    }

    internal struct AnyNavigationDestination: Identifiable {
        public let destination: any NavigationDestination
        public var id: Int { destination.id }
        @MainActor public func asView() -> AnyView { destination.asView() }
    }

    internal struct WeakNavigator {
        weak var navigator: Navigator?
    }

}

extension Navigator {

    @MainActor
    public func navigate(to destination: any NavigationDestination) {
        navigate(to: destination, via: destination.method)
    }

    @MainActor
    public func navigate(to destination: any NavigationDestination, via method: NavigationMethod) {
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
    public func push(_ destination: any NavigationDestination) {
        path.append(destination)
    }

    @MainActor
    public func pop(to position: Int) {
        if position <= path.count {
            path.removeLast(path.count - position)
        }
    }

    @MainActor
    public func pop(last k: Int = 1) {
        if path.count >= k {
            path.removeLast(k)
        }
    }

    @MainActor
    public func popAll() {
        path.removeLast(path.count)
    }

    @MainActor
    public var isEmpty: Bool {
        path.isEmpty
    }

    @MainActor
    public var count: Int {
        path.count
    }

}

extension Navigator {

    @MainActor
    @discardableResult
    public func dismiss() -> Bool {
        if isPresented {
            dismissible?()
            dismissible = nil
            return true
        }
        return false
    }

    @MainActor
    @discardableResult
    public func dismissAll() -> Bool {
        root.dismissAllChildren()
    }

    @MainActor
    @discardableResult
    public func dismissAllChildren() -> Bool {
        for child in children.values {
            if let navigator = child.object, navigator.dismiss() || navigator.dismissAllChildren() {
                return true
            }
        }
        return false
    }

    public nonisolated var isPresented: Bool {
        dismissible != nil
    }

    public nonisolated var isPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false }) != nil
    }

    public nonisolated var isChildPresenting: Bool {
        children.values.first(where: { $0.object?.isPresented ?? false || $0.object?.isChildPresenting ?? false }) != nil
    }

}

struct WeakObject<T: AnyObject> {
    weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension EnvironmentValues {
    @Entry public var navigator: Navigator = Navigator.root
}

extension Navigator {
    // Exists since EnvironmentValues loves to recreate default values
    nonisolated(unsafe) internal static let root: Navigator = Navigator()
}
