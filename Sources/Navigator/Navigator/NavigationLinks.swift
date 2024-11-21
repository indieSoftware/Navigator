//
//  NavigationLinks.swift
//  Navigator
//
//  Created by Michael Long on 11/21/24.
//

import SwiftUI

public protocol NavigationLinkHander {
    func handles(_ url: URL) -> [any Hashable]?
}

extension Navigator {
    @MainActor public func openURL(_ url: URL) {
        if let destinations = configuration.handles(url) {
            send(values: destinations)
        }
    }
}
