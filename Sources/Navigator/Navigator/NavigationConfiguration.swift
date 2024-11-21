//
//  NavigationConfiguration.swift
//  Navigator
//
//  Created by Michael Long on 11/21/24.
//

import SwiftUI

open class NavigationConfiguration {

    public var log: ((String) -> Void)? = {
        print($0)
    }

    internal var linkHanders: [NavigationLinkHander] = []

    public init(logger: @escaping (String) -> Void, linkHanders: [any NavigationLinkHander] = []) {
        self.log = logger
        self.linkHanders = linkHanders
    }

    public init(linkHanders: [any NavigationLinkHander] = []) {
        self.linkHanders = linkHanders
    }

    public func handles(_ url: URL) -> [any Hashable]? {
       for handler in linkHanders {
            if let destinations = handler.handles(url) {
                return destinations
            }
        }
        return nil
    }
    
}
