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
        Section {
            Button("Button Presents Page Sheet") {
                navigator.navigate(to: HomeDestinations.sheet, via: .sheet)
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
        Section {
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
        Section {
            Button("Return To Checkpoint Home") {
                navigator.returnToCheckpoint("home")
            }
            Button("Return To Checkpoint Page 2") {
                navigator.returnToCheckpoint(HomeDestinations.page2)
            }
       }
    }
}

#Preview {
    HomeContentView(name: "Content")
}
