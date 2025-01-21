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
        ManagedNavigationStack(scene: RootTabs.settings.id) {
            SettingsView(name: "Root Settings")
                .navigationDestinationAutoReceive(SettingsDestinations.self)
        }
    }
}

struct SettingsView: View {
    let name: String
    @Environment(\.navigator) var navigator: Navigator
    @State var triggerPage3: Bool = false
    @State var destination: SettingsDestinations?
    @State var returnValue: Int? = nil
    var body: some View {
        List {
            Section("Sheet Actions") {
                Button("Settings Sheet With Return Value") {
                    navigator.navigate(to: SettingsDestinations.sheet)
                }
                Text("Return Value: \(String(describing: returnValue))")
                    .foregroundStyle(.secondary)
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
                    navigator.send(value: SettingsDestinations.page2)
                }
                Button("Send Page 3 via Modifier") {
                    destination = SettingsDestinations.page3
                }
                .navigationSend($destination)
                Button("Send Tab Home, Page 2, 88, Present") {
                    navigator.send(values: [
                        NavigationAction.dismissAll,
                        RootTabs.home,
                        HomeDestinations.page2,
                        HomeDestinations.pageN(88),
                        HomeDestinations.presented1
                    ])
                }
            }

            Section("Resume Actions") {
                Button("Present Resumable Loading View") {
                    navigator.send(values: [
                        SettingsDestinations.presentLoading,
                        LoadingDestinations.external,
                    ])
                }

            }
        }
        .navigationTitle(name)
        // establishes a checkpoint with a return value handler
        .navigationCheckpoint(.settings) { (result: Int?) in
            returnValue = result
        }
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
            CustomSettingsSheetSection()
            ContentPopSection()
        }
        .navigationCheckpoint(.page2)
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
            Section("Checkpoint Actions") {
                Button("Return to Settings Checkpoint Value 5") {
                    navigator.returnToCheckpoint(.settings, value: 5)
                }
                Button("Return to Settings Checkpoint Value 0") {
                    navigator.returnToCheckpoint(.settings, value: 0)
                }
                Button("Return to Missing Settings Handler 0.0") {
                    navigator.returnToCheckpoint(.settings, value: 0.0)
                }
            }
            Section("Send Actions") {
                Button("Send Tab Home") {
                    navigator.send(values: [
                        NavigationAction.dismissAll,
                        RootTabs.home
                    ])
                }
            }
            ContentSheetSection()
        }
        .navigationTitle("Sheet")
    }
}

struct SettingsExternalView: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Text("External View")
        }
        .navigationTitle("External View")
    }
}

struct PresentLoadingView: View {
    @State var Loading: Bool = true
    var body: some View {
        ManagedNavigationStack {
            List {
                if Loading {
                    Text("Loading...")
                        .task {
                            try? await Task.sleep(for: .seconds(3))
                            self.Loading = false
                        }
                } else {
                    Text("Loaded...")
                        .navigationResume() // resume when this view appears
                }
            }
            .navigationDestinationAutoReceive(LoadingDestinations.self)
            .navigationTitle("Presented View")
        }
    }
}
