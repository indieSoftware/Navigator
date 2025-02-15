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
                    ExampleListItem(title: example.title, description: example.description) {
                        navigator.navigate(to: example)
                    }
                }
            }
            .navigationTitle("Examples")
        }
    }
}

struct ExampleListItem: View {
    var title: String
    var description: String
    var action: () -> Void
    var body: some View {
        VStack(alignment: .leading) {
            Button(title) {
                action()
            }
            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ExamplesView()
}
