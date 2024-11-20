//
//  NavigationCheckpoint.swift
//  Navigator
//
//  Created by Michael Long on 11/20/24.
//

import SwiftUI

extension Navigator {

    @MainActor
    public func returnToCheckpoint(_ name: String) {
        guard let found = checkpoints[name], let index = found.checkpoint?.index else {
            parent?.returnToCheckpoint(name)
            return
        }
        dismissAllChildren()
        pop(to: index)
    }

    @MainActor
    public func returnToCheckpoint(_ hashable: any Hashable) {
        returnToCheckpoint("\(hashable.hashValue)")
    }

    internal func addCheckpoint(_ checkpoint: NavigationCheckpoint) {
        guard checkpoints[checkpoint.name] == nil else { return }
        checkpoint.navigator = self
        checkpoint.index = path.count
        checkpoints[checkpoint.name] = WeakCheckpoint(name: checkpoint.name, checkpoint: checkpoint)
    }

    internal func removeCheckpoint(_ name: String) {
        checkpoints.removeValue(forKey: name)
    }

    internal func cleanCheckpoints() {
        checkpoints = checkpoints.filter { $1.checkpoint != nil }
    }

    internal struct WeakCheckpoint: Hashable {
        let name: String
        weak var checkpoint: NavigationCheckpoint?
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        static func == (lhs: Navigator.WeakCheckpoint, rhs: Navigator.WeakCheckpoint) -> Bool {
            lhs.name == rhs.name
        }
    }

}

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

extension View {
    public func navigationCheckpoint(_ name: String) -> some View {
        self.modifier(NavigationCheckpointModifier(name: name))
    }
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
            .modifier(WrappedCheckpointModifier(navigator: navigator, checkpoint: checkpoint))
    }
    
    struct WrappedCheckpointModifier:  ViewModifier {
        init(navigator: Navigator, checkpoint: NavigationCheckpoint) {
            navigator.addCheckpoint(checkpoint)
        }
        func body(content: Content) -> some View {
            content
        }
    }
    
}
