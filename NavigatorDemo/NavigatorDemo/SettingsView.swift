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
        ManagedNavigationStack(scene: "settings") {
            SettingsView(name: "Root Settings")
                .navigationCheckpoint(.home)
                .navigationDestination(SettingsDestinations.self)
                .onNavigationReceive(SettingsDestinations.self)
        }
    }
}

struct SettingsCompletion: Hashable {
    let value: Int
}

struct SettingsView: View {
    let name: String
    @Environment(\.navigator) var navigator: Navigator
    @State var triggerPage3: Bool = false
    @State var destinationSend: SettingsDestinations?
    var body: some View {
        List {
            Section("Sheet Actions") {
                Button("Present Settings Sheet") {
                    navigator.navigate(to: SettingsDestinations.sheet)
                }
                .onNavigationReceive { (result: SettingsCompletion) in
                    print(result.value)
                    return .checkpoint(.settings)
                }
                .navigationCheckpoint(.settings)
            }

            Section("Navigation Actions") {
                NavigationLink(value: SettingsDestinations.page2) {
                    Text("Link to Settings Page 2!")
                }
                Button("Navigator Push to Settings Page 3!") {
                    navigator.push(SettingsDestinations.page3)
                }
                Button("Modifier Navigate to Settings Page 3!") {
                    triggerPage3.toggle()
                }
                .navigate(trigger: $triggerPage3, destination: SettingsDestinations.page3)
            }

            Section("Send Actions") {
                Button("Send Page 2 via Navigator") {
                    navigator.send(SettingsDestinations.page2)
                }
                Button("Send Page 3 via Modifier") {
                    destinationSend = SettingsDestinations.page3
                }
                .navigationSend($destinationSend)
                Button("Send Tab Home, Page 2") {
                    navigator.send(values: [RootTabs.home, HomeDestinations.page2])
                }
            }
        }
        .navigationTitle(name)
    }
}

struct Page2SettingsView: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section("Navigation Actions") {
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

struct SettingsSheetView: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section("Send Actions") {
                Button("Send Tab Home") {
                    navigator.send(RootTabs.home)
                }
                Button("Send Settings Sheet Completion") {
                    // trigger completion
                    navigator.send(SettingsCompletion(value: 5))
                }
            }
            ContentSheetSection()
        }
        .navigationTitle("Sheet")
    }
}

