//
//  NavigationPage.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

public protocol NavigationDestination: Hashable, Identifiable {

    associatedtype Body: View

    var method: NavigationMethod { get }

    @MainActor @ViewBuilder var body: Self.Body { get }

}

extension NavigationDestination {

    public var id: Int {
        self.hashValue
    }

    public var method: NavigationMethod {
        .push
    }

    @MainActor public func asView() -> AnyView {
        AnyView(self.body)
    }

}

extension View {
    public func navigationDestination<T: NavigationDestination>(_ type: T.Type) -> some View {
        self.navigationDestination(for: type) { destination in
            destination.asView()
        }
    }
}
