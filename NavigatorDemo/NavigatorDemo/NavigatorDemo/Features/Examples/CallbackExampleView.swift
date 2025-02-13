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
                    Button("Present Callback Sheet") {
                        navigator.navigate(to: Destinations.destination1(value, .init {
                            value = $0
                            navigator.dismissPresentedViews()
                        }), method: .sheet)
                    }
                    Button("Dismiss Example") {
                        navigator.dismiss()
                    }
                }
            }
            .navigationTitle("Callback Example")
        }
    }
}

extension CallbackExampleView {
    enum Destinations: NavigationDestination {
        case destination1(Double, Callback<Double>)
        var view: some View {
            switch self {
            case .destination1(let value, let callback):
                PresentedCallbackExampleView(value: value, handler: callback.handler)
            }
        }
    }
}

struct PresentedCallbackExampleView: View {
    @State var value: Double
    let handler: (Double) -> Void
    var body: some View {
        ManagedNavigationStack { navigator in
            List {
                Section {
                    Text("Callback Value: \(Int(value))")
                    Slider(value: $value, in: 1...10, step: 1)
                }
                Button("Callback With Value: \(Int(value))") {
                    handler(value)
                }
                Button("Dismiss") {
                    navigator.dismiss()
                }
            }
            .navigationTitle("Callback Example")
        }
    }

}
