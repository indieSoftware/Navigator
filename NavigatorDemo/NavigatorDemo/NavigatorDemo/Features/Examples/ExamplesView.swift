//
//  ExamplesView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 2/4/25.
//

import Navigator
import SwiftUI

struct ExamplesView: View {
    var body: some View {
        ManagedNavigationStack(name: RootTabs.examples.id) { navigator in
            List {
                ForEach(ExampleDestinations.allCases) { example in
                    VStack(alignment: .leading) {
                        Button(example.title) {
                            navigator.navigate(to: example)
                        }
                        Text(example.description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Examples")
        }
    }
}

#Preview {
    ExamplesView()
}
