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
        guard let found = checkpoints[name], let index = found.object?.index else {
            parent?.returnToCheckpoint(name)
            return
        }
        dismissAllChildren()
        pop(to: index)
    }

    /// Returns to a named checkpoint in the navigation system.
    ///
    /// This function will pop and/or dismiss intervening views as needed.
    @MainActor
    public func returnToCheckpoint(_ hashable: any Hashable) {
        returnToCheckpoint("\(hashable.hashValue)")
    }

    internal func addCheckpoint(_ checkpoint: NavigationCheckpoint) {
        guard checkpoints[checkpoint.name] == nil else { return }
        log("Navigator adding checkpoint \(checkpoint.name)")
        checkpoint.navigator = self
        checkpoint.index = path.count
        checkpoints[checkpoint.name] = WeakObject(checkpoint)
    }

    internal func removeCheckpoint(_ name: String) {
        log("Navigator removing checkpoint \(name)")
        checkpoints.removeValue(forKey: name)
    }

}

extension View {
    /// Establishes a named checkpoint in the navigation system.
    ///
    /// Navigators know how to pop and/or dismiss views in order to return to this checkpoint when needed.
    public func navigationCheckpoint(_ name: String) -> some View {
        self.modifier(NavigationCheckpointModifier(name: name))
    }
    /// Establishes a named checkpoint in the navigation system.
    ///
    /// Navigators know how to pop and/or dismiss views in order to return to this checkpoint when needed.
    public func navigationCheckpoint(_ hashable: any Hashable) -> some View {
        self.modifier(NavigationCheckpointModifier(name: "\(hashable.hashValue)"))
    }
}

internal struct NavigationCheckpointModifier: ViewModifier {

    @StateObject var checkpoint: NavigationCheckpoint
    @Environment(\.navigator) var navigator: Navigator

    init(name: String) {
        self._checkpoint = .init(wrappedValue: .init(name: name))
    }

    func body(content: Content) -> some View {
        content
            .modifier(WrappedModifier(navigator: navigator, checkpoint: checkpoint))
    }
    
    // Wrapped modifier allows parent environment variables can be extracted and passed to navigator.
    struct WrappedModifier:  ViewModifier {
        init(navigator: Navigator, checkpoint: NavigationCheckpoint) {
            navigator.addCheckpoint(checkpoint)
        }
        func body(content: Content) -> some View {
            content
        }
    }
    
}

/// The NavigationCheckpoint sentinel removes checkpoints when host views are popped or dismissed.
internal class NavigationCheckpoint: ObservableObject {
    var name: String
    weak var navigator: Navigator? = nil
    var index: Int = 0
    init(name: String) {
        self.name = name
    }
    deinit {
        navigator?.removeCheckpoint(name)
    }
}
