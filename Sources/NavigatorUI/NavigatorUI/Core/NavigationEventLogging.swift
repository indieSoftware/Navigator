//
//  NavigationEventLogging.swift
//  Navigator
//
//  Created by Michael Long on 3/17/25.
//

import Foundation

extension Navigator {
    internal func log(_ event: NavigationEvent.Event) {
        state.log(event)
    }
}

extension NavigationState {
    internal func log(_ event: NavigationEvent.Event) {
        guard let configuration, let logger = configuration.logger else {
            return
        }
        let verbosity: NavigationEvent.Verbosity
        switch event {
        case .warning:
            verbosity = .warning
        case .error:
            verbosity = .error
        default:
            verbosity = .info
        }
        guard verbosity.rawValue >= configuration.verbosity.rawValue else {
            return
        }
        logger(.init(verbosity: .info, navigator: id, event: event, timestamp: Date()))
    }
}

public struct NavigationEvent: CustomStringConvertible {

    let verbosity: Verbosity
    let navigator: UUID
    let event: Event
    let timestamp: Date

    public var description: String {
        "Navigator \(navigator) \(event)"
    }
    
}

extension NavigationEvent {

    public enum Verbosity: Int {
        case info
        case warning
        case error
        case none
    }

}

extension NavigationEvent {

    public enum Event: CustomStringConvertible {

        case lifecycle(LifecycleEvent)
        case navigation(NavigationEvent)
        case checkpoint(CheckpointEvent)
        case send(SendEvent)

        case message(String)
        case warning(String)
        case error(String)

        public var description: String {
            switch self {
            case .lifecycle(let event):
                return "\(event)"
            case .navigation(let event):
                return "\(event)"
            case .checkpoint(let event):
                return "checkpoint \(event)"
            case .send(let event):
                return "\(event)"
            case .message(let message):
                return message
            case .warning(let message):
                return message
            case .error(let message):
                return message
            }
        }

        public enum LifecycleEvent {
            case configured
            case intialized
            case adding(UUID)
            case removing(UUID)
            case `deinit`
        }

        public enum NavigationEvent {
            case presenting(any NavigationDestination)
            case pushing(any Hashable)
            case popping
            case dismissed
        }

        public enum SendEvent {
            case performing(any Hashable)
            case sending(any Hashable)
            case receiving(any Hashable)
        }

        public enum CheckpointEvent {
            case adding(String)
            case removing(String)
            case returning(String)
            case returningWithValue(String, Any)
        }

    }

}
