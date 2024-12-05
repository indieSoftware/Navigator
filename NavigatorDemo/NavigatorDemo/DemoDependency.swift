//
//  DemoDependency.swift
//  NavigatorDemo
//
//  Created by Michael Long on 12/5/24.
//

import Foundation
import Navigator

public protocol DemoDependency {
    var value: Int { get }
}

public var globalDependencies: DemoDependency = MyDemoDependencies()

public struct MyDemoDependencies: DemoDependency {
    public let value: Int = 66
}
