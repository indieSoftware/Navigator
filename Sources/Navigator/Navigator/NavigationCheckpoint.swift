//
//  NavigationCheckpoint.swift
//  Navigator
//
//  Created by Michael Long on 11/20/24.
//

import SwiftUI

public struct NavigationCheckpoint: Codable, Equatable, ExpressibleByStringLiteral {
    internal let name: String
    internal let index: Int
    public init(stringLiteral value: String) {
        self.name = value
        self.index = 0
    }
    internal init(name: String, index: Int) {
        self.name = name
        self.index = index
    }
    internal func setting(index: Int) -> NavigationCheckpoint {
        .init(name: name, index: index)
    }
    public static func == (lhs: NavigationCheckpoint, rhs: NavigationCheckpoint) -> Bool {
        lhs.name == rhs.name
    }
}

extension Navigator {

    /// Returns to a named checkpoint in the navigation system.
    ///
    /// This function will pop and/or dismiss intervening views as needed.
    @MainActor
    @discardableResult
    public func returnToCheckpoint(_ checkpoint: NavigationCheckpoint) -> Bool {
        guard let found = checkpoints[checkpoint.name] else {
            if let parent {
                return parent.returnToCheckpoint(checkpoint)
            } else {
                log("Navigator checkpoint not found: \(checkpoint.name)")
                return false
            }
        }
        log("Navigator returning to checkpoint: \(checkpoint.name)")
        dismissAllChildren()
        pop(to: found.index)
        return true
    }

    public nonisolated func canReturnToCheckpoint(_ checkpoint: NavigationCheckpoint) -> Bool {
        guard let found = checkpoints[checkpoint.name] else {
            return parent?.canReturnToCheckpoint(checkpoint) ?? false
        }
        return found.index < path.count
    }

    internal func addCheckpoint(_ checkpoint: NavigationCheckpoint) {
        guard checkpoints[checkpoint.name] == nil else { return }
        log("Navigator adding checkpoint: \(checkpoint.name)")
        checkpoints[checkpoint.name] = checkpoint.setting(index: path.count)
    }

    internal func cleanCheckpoints() {
        checkpoints = checkpoints.filter { $1.index <= path.count }
    }
}

extension View {

    /// Establishes a named checkpoint in the navigation system.
    ///
    /// Navigators know how to pop and/or dismiss views in order to return to this checkpoint when needed.
    public func navigationCheckpoint(_ checkpoint: NavigationCheckpoint) -> some View {
        self.modifier(NavigationCheckpointModifier(checkpoint: checkpoint))
    }

    public func navigationReturnToCheckpoint(_ checkpoint: Binding<NavigationCheckpoint?>) -> some View {
        self.modifier(NavigationReturnToCheckpointModifier(checkpoint: checkpoint))
    }

    public func navigationReturnToCheckpoint(trigger: Binding<Bool>, checkpoint: NavigationCheckpoint) -> some View {
        self.modifier(NavigationReturnToCheckpointTriggerModifier(trigger: trigger, checkpoint: checkpoint))
    }

}

private struct NavigationCheckpointModifier: ViewModifier {
    @Environment(\.navigator) var navigator: Navigator
    internal let checkpoint: NavigationCheckpoint
    func body(content: Content) -> some View {
        content
            .modifier(WrappedModifier(checkpoint: checkpoint, navigator: navigator))
    }
    // Wrapped modifier allows parent environment variables can be extracted and passed to navigator.
    struct WrappedModifier:  ViewModifier {
        init(checkpoint: NavigationCheckpoint, navigator: Navigator) {
            navigator.addCheckpoint(checkpoint)
        }
        func body(content: Content) -> some View {
            content
        }
    }
}

private struct NavigationReturnToCheckpointModifier: ViewModifier {
    @Binding internal var checkpoint: NavigationCheckpoint?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: checkpoint) { checkpoint in
                if let checkpoint {
                    navigator.returnToCheckpoint(checkpoint)
                    self.checkpoint = nil
                }
            }
    }
}

private struct NavigationReturnToCheckpointTriggerModifier: ViewModifier {
    @Binding internal var trigger: Bool
    internal let checkpoint: NavigationCheckpoint
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger {
                    navigator.returnToCheckpoint(checkpoint)
                    self.trigger = false
                }
            }
    }
}
