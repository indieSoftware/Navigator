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
    var body: some View {
        Section("Presentation Actions") {
            Button("Button Presents Page Sheet") {
                navigator.navigate(to: HomeDestinations.sheet, method: .sheet)
            }
            Button("Button Presents Custom Sheet") {
                showSheet = true
            }
            .sheet(isPresented: $showSheet) {
                CustomContentView()
                    .navigationDismissible()
            }
            Button("Dismiss", role: .cancel) {
                navigator.dismiss()
            }
            .disabled(!navigator.isPresented)
            Button("Dismiss All") {
                navigator.dismissAll()
            }
            .disabled(!navigator.isPresented)
        }
    }
}

struct ContentPopSection: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        Section("Checkpoint Actions") {
            Button("Return To Checkpoint Home") {
                navigator.returnToCheckpoint("home")
            }
            Button("Return To Checkpoint Page 2") {
                navigator.returnToCheckpoint("page2")
            }
        }
        Section("Pop Actions") {
            Button("Button Pop") {
                navigator.pop()
            }
            .disabled(navigator.isEmpty)
            Button("Button Pop To 2") {
                navigator.pop(to: 1) // count from zero
            }
            .disabled(navigator.isEmpty)
            Button("Button Pop All") {
                navigator.popAll()
            }
            .disabled(navigator.isEmpty)
        }
    }
}

#Preview {
    HomeContentView(name: "Content")
}
