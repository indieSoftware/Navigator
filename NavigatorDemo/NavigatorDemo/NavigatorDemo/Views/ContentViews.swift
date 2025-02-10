//
//  ContentView.swift
//  Nav5
//
//  Created by Michael Long on 11/10/24.
//

import Navigator
import SwiftUI

struct CustomContentView: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            ContentSheetSection()
        }
    }
}

struct ContentSheetSection: View {
    @Environment(\.navigator) var navigator: Navigator
    @State var showSheet: Bool = false
    @State var dismiss: Bool = false
    @State var dismissAny: Bool = false
    var body: some View {
        Section("Presentation Actions") {
            Button("Present Navigation View via Sheet") {
                navigator.navigate(to: HomeDestinations.presented1)
            }

            Button("Present Locked Navigation View via Cover") {
                navigator.navigate(to: HomeDestinations.presented2)
            }

            Button("Present Dismissible View") {
                showSheet = true
            }
            .sheet(isPresented: $showSheet) {
                CustomContentView()
                    .managedPresentationView()
            }

            Button("Dismiss", role: .cancel) {
                dismiss = true
            }
            .navigationDismiss(trigger: $dismiss)
            .disabled(!navigator.isPresented)

            Button("Dismiss Any") {
                dismissAny = true
            }
            .navigationDismissAny(trigger: $dismissAny)
            .disabled(!navigator.isPresented)
        }
    }
}

struct ContentCheckpointSection: View {
    @Environment(\.navigator) var navigator: Navigator
    @Environment(\.dismiss) var dismiss
    @State var returnToCheckpoint: Bool = false
    var body: some View {
        Section("Checkpoint Actions") {
            Button("Return To Checkpoint Home") {
                navigator.returnToCheckpoint(.home)
            }
            .disabled(!navigator.canReturnToCheckpoint(.home))

            Button("Return To Checkpoint Page 2") {
                returnToCheckpoint = true
            }
            .navigationReturnToCheckpoint(trigger: $returnToCheckpoint, checkpoint: .page2)
            .disabled(!navigator.canReturnToCheckpoint(.page2))

            Button("Return To Checkpoint Duplicate (1, 2)") {
                navigator.returnToCheckpoint(.duplicate)
            }
            .disabled(!navigator.canReturnToCheckpoint(.duplicate))

            Button("Return To Checkpoint Settings") {
                navigator.returnToCheckpoint(.settings)
            }
            .disabled(!navigator.canReturnToCheckpoint(.settings))

            Button("Return to Settings Checkpoint Value 9") {
                navigator.returnToCheckpoint(.settings, value: 9)
            }

            Button("Return To Unknown Checkpoint") {
                navigator.returnToCheckpoint("unknown")
            }
        }
    }
}

struct ContentRoutingSection: View {
    @Environment(\.navigator) var navigator
    @Environment(\.homeDependencies) var resolver
    @State var returnToCheckpoint: Bool = false
    var body: some View {
        Section("Routing Actions") {
            Button("Route To Home Page 2, 3") {
                navigator.perform(route: KnownRoutes.homePage2Page3)
            }
            Button("Route To Home Page 2, 3, 99") {
                navigator.perform(route: KnownRoutes.homePage2Page3PageN(99))
            }
            Button("Route To Settings Page 2") {
                resolver.homeExternalRouter.route(to: .settingsPage2)
            }
        }
    }
}

struct ContentPopSection: View {
    @Environment(\.navigator) var navigator: Navigator
    @Environment(\.dismiss) var dismiss
    @State var returnToCheckpoint: Bool = false
    var body: some View {
        Section("Pop Actions") {
            Button("Pop Current Screen") {
                navigator.pop()
            }
            .disabled(navigator.isEmpty)

            Button("Pop To 2nd Screen") {
                navigator.pop(to: 1) // count from zero
            }
            .disabled(navigator.isEmpty)

            Button("Pop All Screens") {
                navigator.popAll()
            }
            .disabled(navigator.isEmpty)
         }

        Section("Classic Actions") {
            Button("Go Back") {
                navigator.back()
            }

            Button("Dismiss") {
                dismiss()
            }
        }

    }
}

struct CustomSettingsSheetSection: View {
    @State var showSettings: SettingsDestinations?
    var body: some View {
        Section {
            Button("Present Page 2 via Sheet") {
                showSettings = .page2
            }
            Button("Present Page 3 via Sheet") {
                showSettings = .page3
            }
            .sheet(item: $showSettings) { destination in
                destination()
                    .managedPresentationView()
            }
        }
    }
}
