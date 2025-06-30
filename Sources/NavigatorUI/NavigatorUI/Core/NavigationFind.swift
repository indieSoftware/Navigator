//
//  NavigationFind.swift
//  Navigator
//
//  Created by Michael Long on 1/18/25.
//

import SwiftUI

extension Navigator {

    /// Returns first navigator found with given name
    @MainActor public func named(_ name: String) -> Navigator? {
        if let state = state.root.recursiveFind(name: name) {
            return Navigator(state: state)
        }
        return nil
    }

    /// Returns child navigator found with given name
    @MainActor public func child(named name: String) -> Navigator? {
        if let state = state.recursiveFind(name: name) {
            return Navigator(state: state)
        }
        return nil
    }

}

extension NavigationState {
    
    /// Finds a named state within the navigation tree
    internal func recursiveFind(name: String) -> NavigationState? {
        if self.name == name {
            return self
        }
        for child in children.values {
            if let navigator = child.object, let found = navigator.recursiveFind(name: name) {
                return found
            }
        }
        return nil
    }

}
