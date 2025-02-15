//
//  CallbackExample.swift
//  Navigator
//
//  Created by Michael Long on 2/12/25.
//

import Navigator
import SwiftUI

struct CallbackExampleView: View {
    @State var value: Double = 0
    var body: some View {
        ManagedNavigationStack { navigator in
            List {
                Section {
                    Text("Callback Value: \(Int(value))")
                }
                Section {
                    ExampleListItem(
                        title: "Present Callback Sheet w/Dismiss",
                        description: "Callback handler dismisses presented views with dismissPresentedViews.",
                        action: {
                            navigator.navigate(to: CallbackDestinations.presented(value, .init {
                                value = $0
                                navigator.dismissPresentedViews()
                            }))
                        }
                    )
                    ExampleListItem(
                        title: "Present Callback Sheet w/Checkpoint",
                        description: "Callback handler dismisses presented views with returnToCheckpoint(.home).",
                        action: {
                            navigator.navigate(to: CallbackDestinations.presented(value, .init {
                                value = $0
                                navigator.returnToCheckpoint(.home)
                            }))
                        }
                    )
                }
                Section {
                    ExampleListItem(
                        title: "Push Callback View",
                        description: "Callback handler dismisses presented views with returnToCheckpoint(.home).",
                        action: {
                            navigator.navigate(to: CallbackDestinations.pushed(value, .init {
                                value = $0
                                navigator.returnToCheckpoint(.home)
                            }))
                        }
                    )
                }
                Section {
                    Button("Dismiss Example") {
                        navigator.dismiss()
                    }
                }
            }
            .navigationDestination(CallbackDestinations.self)
            // illustrates returning to named checkpoint instead of trying to pop or dismiss
            .navigationCheckpoint(.home)
            // illustrates returning to named checkpoint with value instead of using callback handler
            .navigationCheckpoint(.home) { (value: Double) in
                self.value = value
            }
            .navigationTitle("Callback Example")
        }
    }
}

enum CallbackDestinations: NavigationDestination {

    case presented(Double, Callback<Double>)
    case pushed(Double, Callback<Double>)

    var view: some View {
        switch self {
        case .presented(let value, let callback):
            CallbackReturnView(value: value, handler: callback.handler)
        case .pushed(let value, let callback):
            CallbackReturnView(value: value, handler: callback.handler)
        }
    }

    var method: NavigationMethod {
        switch self {
        case .presented:
            return .managedSheet
        case .pushed:
            return .push
        }
    }
}

struct CallbackReturnView: View {
    @State var value: Double
    @Environment(\.navigator) var navigator
    let handler: (Double) -> Void
    var body: some View {
        List {
            Section {
                Text("Callback Value: \(Int(value))")
                Slider(value: $value, in: 1...10, step: 1)
            }
            Section {
                ExampleListItem(
                    title: "Callback With Value: \(Int(value))",
                    description: "Calls passed callback handler with current value.",
                    action: { handler(value) }
                )
                ExampleListItem(
                    title: "Return To Checkpoint With Value: \(Int(value))",
                    description: "Demonstrates bypassing the callback handler with returnToCheckpoint(:value:).",
                    action: {
                        navigator.returnToCheckpoint(.home, value: value)
                    }
                )
            }
            Section {
                Button("Dismiss") {
                    navigator.returnToCheckpoint(.home)
                }
            }
        }
        .navigationTitle("Callback View")
    }
}
