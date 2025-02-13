//
//  ExampleDestinations.swift
//  NavigatorDemo
//
//  Created by Michael Long on 2/4/25.
//

import Navigator
import SwiftUI

public enum ExampleDestinations: String, NavigationDestination, CaseIterable {

    case binding
    case callback
    case transition

    public var view: some View {
        switch self {
        case .binding:
            BindingExampleView()
        case .callback:
            CallbackExampleView()
        case .transition:
            if #available(iOS 18.0, *) {
                TransitionExampleView()
            } else {
                NotAvailableView()
            }
        }
    }

    public var method: NavigationMethod {
        .cover
    }

    public var title: String {
        rawValue.capitalized
    }

    public var description: String {
        switch self {
        case .binding:
            "Demonstrates using a binding in navigation destinations."
        case .callback:
            "Demonstrates using a callback handler in navigation destinations."
        case .transition:
            "Demonstrates custom transitions with navigation destinations. (iOS 18.0+)"
        }
    }

}

private struct NotAvailableView: View {
    @Environment(\.navigator) var navigator
    var body: some View {
        List {
            Text("Not Available")
            Button("Dismiss") {
                navigator.dismiss()
            }
        }
    }
}
