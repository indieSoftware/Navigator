//
//  NavigationCheckpoint.swift
//  Navigator
//
//  Created by Michael Long on 11/20/24.
//

import SwiftUI

extension Navigator {

    /// Returns to a named checkpoint in the navigation system.
    ///
    /// This function will pop and/or dismiss intervening views as needed.
    @MainActor
    public func returnToCheckpoint(_ name: String) {
        guard let found = checkpoints[name] else {
            parent?.returnToCheckpoint(name)
            return
        }
        dismissAllChildren()
        pop(to: found.index)
    }

    internal func addCheckpoint(_ name: String) {
        guard checkpoints[name] == nil else { return }
        log("Navigator adding checkpoint \(name)")
        checkpoints[name] = NavigationCheckpoint(name: name, index: path.count)
    }

    internal func cleanCheckpoints() {
        checkpoints = checkpoints.filter { $1.index <= path.count }
    }
}

internal struct NavigationCheckpoint: Codable {
    let name: String
    let index: Int
}

extension View {
    /// Establishes a named checkpoint in the navigation system.
    ///
    /// Navigators know how to pop and/or dismiss views in order to return to this checkpoint when needed.
    public func navigationCheckpoint(_ name: String) -> some View {
        self.modifier(NavigationCheckpointModifier(name: name))
    }
}

internal struct NavigationCheckpointModifier: ViewModifier {

    @Environment(\.navigator) var navigator: Navigator

    private let name: String

    init(name: String) {
        self.name = name
    }

    func body(content: Content) -> some View {
        content
            .modifier(WrappedModifier(name: name, navigator: navigator))
    }
    
    // Wrapped modifier allows parent environment variables can be extracted and passed to navigator.
    struct WrappedModifier:  ViewModifier {
        init(name: String, navigator: Navigator) {
            navigator.addCheckpoint(name)
        }
        func body(content: Content) -> some View {
            content
        }
    }

}
