//
//  NavigationFlow.swift
//  NavigatorUI
//
//  Created by Michael Long on 10/25/25.
//

import SwiftUI

@MainActor
public protocol NavigationFlow: Hashable {

    associatedtype Destination: NavigationDestination

    var checkpoint: NavigationFlowCheckpoint? { get set }

    func start() -> FlowResult<Destination>
    mutating func next() -> FlowResult<Destination>

    func onComplete()
    func onCancel()
    func onError(_ error: Error)

}

extension NavigationFlow {
    public func onComplete() {}
    public func onCancel() {}
    public func onError(_ error: Error) {}
}

public enum FlowResult<Destination> {
    case destination(Destination)
    case complete
    case cancel
    case error(Error)
}

extension Navigator {

    @MainActor public func start(_ flow: some NavigationFlow) {
        var mutableFlow = flow
        mutableFlow.checkpoint = .init(index: count, state: state)
        switch mutableFlow.start() {
        case .destination(let destination):
            navigate(to: destination)
        case .complete:
            complete(mutableFlow)
        case .cancel:
            cancel(mutableFlow)
        case .error(let e):
            error(mutableFlow, error: e)
        }
    }

    @MainActor public func next(_ flow: some NavigationFlow) {
        var mutableFlow = flow
        switch mutableFlow.next() {
        case .destination(let destination):
            navigate(to: destination)
        case .complete:
            complete(mutableFlow)
        case .cancel:
            cancel(mutableFlow)
        case .error(let e):
            error(mutableFlow, error: e)
        }
    }

    @MainActor public func complete(_ flow: some NavigationFlow) {
        guard let checkpoint = flow.checkpoint else { return }
        if let state = checkpoint.state {
            state.returnToIndex(checkpoint.index)
            flow.onComplete()
        }
    }

    @MainActor public func cancel(_ flow: some NavigationFlow) {
        guard let checkpoint = flow.checkpoint else { return }
        if let state = checkpoint.state {
            state.returnToIndex(checkpoint.index)
            flow.onCancel()
        }
    }

    @MainActor public func error(_ flow: some NavigationFlow, error: Error) {
        guard let checkpoint = flow.checkpoint else { return }
        if let state = checkpoint.state {
            state.returnToIndex(checkpoint.index)
            flow.onError(error)
        }
    }

}

public typealias NavigationFlowCheckpoint = IndexedNavigationCheckpoint

@MainActor
public struct IndexedNavigationCheckpoint {
    internal let index: Int
    internal weak var state: NavigationState?
}

extension IndexedNavigationCheckpoint: Hashable, Equatable {

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
        if let state {
            hasher.combine(ObjectIdentifier(state).hashValue)
        }
    }

    nonisolated public static func == (lhs: Self, rhs: Self) -> Bool {
        if let lState = lhs.state, let rState = rhs.state {
            lhs.index == rhs.index && ObjectIdentifier(lState) == ObjectIdentifier(rState)
        } else {
            lhs.index == rhs.index
        }
    }
}

//@MainActor
//public struct SimpleNavigationFlow<D: NavigationDestination> {
//    private let items: [D]
//    private var index: Int = 0
//
//    public init(items: [D]) {
//        self.items = items
//    }
//
//    public func start() -> FlowResult<D> {
//        guard let first = items.first else {
//            return .complete
//        }
//        return .destination(first)
//    }
//    
//    public mutating func next() -> FlowResult<D> {
//        index += 1
//        guard index < items.count else {
//            return .complete
//        }
//        return .destination(items[index])
//    }
//}
