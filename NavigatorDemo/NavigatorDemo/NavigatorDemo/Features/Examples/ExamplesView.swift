//
//  ExamplesView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 2/4/25.
//

import NavigatorUI
import SwiftUI

struct ExamplesView: View {
    var body: some View {
        ManagedNavigationStack(name: RootTabs.examples.id) { navigator in
            List {
                ForEach(ExampleDestinations.allCases) { example in
                    ExampleListButton(title: example.title, text: example.description) {
                        navigator.navigate(to: example)
                    }
                }
            }
            .navigationTitle("Examples")
        }
    }
}

struct ExampleListButton: View {
    var title: String
    var text: String
    var action: () -> Void
    var body: some View {
        VStack(alignment: .leading) {
            Button(title) {
                action()
            }
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ExamplesView()
}
