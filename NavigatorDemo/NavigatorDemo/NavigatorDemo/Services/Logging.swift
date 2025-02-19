//
//  Logging.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/30/25.
//

import Foundation

public protocol Logging {
    func log(_ message: String)
}

public struct Logger: Logging {
    public func log(_ message: String) {
        print(message)
    }
}
