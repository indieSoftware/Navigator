//
//  DummyServices.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/24/25.
//

import Foundation

//
// MISCELLANEOUS SERVICE PROTOCOLS AND MOCKS
//

public protocol Loading {
    func load() -> String
}

public struct Loader: Loading {
    let networker: Networking
    public func load() -> String {
        networker.load() ?? "?"
    }
}

public protocol SettingsProviding {
    func settings() -> [String]
}

public struct SettingsProvider: SettingsProviding {
    public func settings() -> [String] {
        []
    }
}
