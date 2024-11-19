//
//  NavigationPage.swift
//  Navigator
//
//  Created by Michael Long on 11/10/24.
//

import SwiftUI

public protocol NavigationDestinations: Hashable, Identifiable {

    associatedtype Body: View

    var method: NavigationMethod { get }

    @MainActor @ViewBuilder var body: Self.Body { get }

}

extension NavigationDestinations {

    public var id: Int {
        return self.hashValue
    }

    public var method: NavigationMethod {
        .push
    }

    @MainActor public var asView: AnyView {
        AnyView(self.body)
    }

}

extension View {
    public func navigationDestinations<T: NavigationDestinations>(_ type: T.Type) -> some View {
        self.navigationDestination(for: type) { destination in
            destination.asView
        }
    }
}
