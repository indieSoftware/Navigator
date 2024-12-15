//
//  DemoDependency.swift
//  NavigatorDemo
//
//  Created by Michael Long on 12/5/24.
//

import SwiftUI
import Navigator

extension EnvironmentValues {
    @Entry var coreDependencies: CoreDependencies = MockAppResolver()
}

protocol CoreDependencies {
    func networking() -> Networking
}

extension CoreDependencies {
    func networking() -> Networking {
        Networker()
    }
}

struct AppResolver: CoreDependencies {

}

struct MockAppResolver: CoreDependencies {
    func networking() -> Networking {
        MockNetworker()
    }
}

protocol Networking {
    func load() -> String
}

struct Networker: Networking {
    func load() -> String { "(A)" }
}

struct MockNetworker: Networking {
    func load() -> String { "(M)" }
}
