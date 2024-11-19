//
//  SettingsView 2.swift
//  Nav5
//
//  Created by Michael Long on 11/18/24.
//

import Navigator
import SwiftUI

struct RootSettingsView: View {
    var body: some View {
        ManagedNavigationStack {
            SettingsView(name: "Root Settings")
                .navigationDestinations(SettingsDestinations.self)
                .onNavigationReceive(SettingsDestinations.self)
        }
    }
}

struct SettingsView: View {
    let name: String
    @Environment(\.navigator) var navigator: Navigator
    @State var text: String = ""
    var body: some View {
        List {
            Section {
                NavigationLink(value: SettingsDestinations.page2) {
                    Text("Link to Settings Page 2!")
                }
                Button("Button Push to Settings Page 3!") {
                    navigator.push(SettingsDestinations.page3)
                }
            }
            Section {
                Button("Send Settings Page 3") {
                    navigator.send(SettingsDestinations.page3)
                }
                Button("Send Tab Home, Page 2") {
                    navigator.send(values: [RootTabs.home, HomeDestinations.page2])
                }
            }
        }
        .navigationTitle(name)
        .searchable(text: $text)
    }
}

struct Page2SettingsView: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section {
                NavigationLink(value: SettingsDestinations.page3) {
                    Text("Link to Test Page 3!")
                }
            }
            ContentPopSection()
        }
        .navigationTitle("Page 2")
    }
}

struct Page3SettingsView: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            ContentPopSection()
        }
        .navigationTitle("Page 3")
    }
}
