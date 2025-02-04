//
//  ExamplesView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 2/4/25.
//

import Navigator
import SwiftUI

struct ExamplesRootView: View {
    var body: some View {
        ManagedNavigationStack {
            ExamplesListView()
                .navigationTitle("Examples")
        }
    }
}

struct ExamplesListView: View {
    @Environment(\.navigator) var navigator
    var body: some View {
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
    }
}

#Preview {
    ExamplesRootView()
}
