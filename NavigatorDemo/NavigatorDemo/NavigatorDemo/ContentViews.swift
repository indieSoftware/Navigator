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
    @State var dismissAll: Bool = false
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
                    .navigationDismissible()
            }

            Button("Dismiss", role: .cancel) {
                dismiss = true
            }
            .navigationDismiss(trigger: $dismiss)
            .disabled(!navigator.isPresented)

            Button("Dismiss All") {
                dismissAll = true
            }
            .navigationDismissAll(trigger: $dismissAll)
            .disabled(!navigator.isPresented)
        }
    }
}

struct ContentPopSection: View {
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

            Button("Return To Checkpoint Settings") {
                navigator.returnToCheckpoint(.settings)
            }
            .disabled(!navigator.canReturnToCheckpoint(.settings))

            Button("Return To Unknown Checkpoint") {
                navigator.returnToCheckpoint("unknown")
            }
        }

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
                    .navigationDismissible()
            }
        }
    }
}
