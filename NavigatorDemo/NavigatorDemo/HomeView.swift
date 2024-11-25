//
//  ContentView.swift
//  Nav5
//
//  Created by Michael Long on 11/10/24.
//

import Navigator
import SwiftUI

struct RootHomeView: View {
    var body: some View {
        ManagedNavigationStack(name: "Home") {
            HomeContentView(name: "Root Navigation")
                .navigationCheckpoint("home")
                .navigationDestination(HomeDestinations.self)
                .onNavigationSend { (destination: HomeDestinations, navigator) in
                    navigator.navigate(to: destination)
                    return .auto
                }
        }
    }
}

struct HomeContentView: View {
    let name: String
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section("Navigation Actions") {
                NavigationLink(value: HomeDestinations.page2) {
                    Text("Link to Home Page 2!")
                }
                NavigationLink(value: HomeDestinations.pageN(44)) {
                    Text("Link to Home Page 44!")
                }
                Button("Button Navigate to Home Page 55") {
                    navigator.navigate(to: HomeDestinations.pageN(55))
                }
            }
            Section("Send Actions") {
                Button("Send Home Page 88, 99") {
                    navigator.send(values: [
                        HomeDestinations.pageN(88),
                        HomeDestinations.pageN(99)
                    ])
                }
                Button("Send Tab Settings") {
                    navigator.send(RootTabs.settings)
                }
            }
            ContentSheetSection()
            ContentPopSection()
        }
        .navigationTitle(name)
    }
}

struct HomePage2View: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section("Navigation Actions") {
                NavigationLink(value: HomeDestinations.page3) {
                    Text("Link to Home Page 3!")
                }
                NavigationLink(value: HomeDestinations.pageN(55)) {
                    Text("Link to Home Page 55!")
                }
            }
            ContentSheetSection()
            ContentPopSection()
        }
        .navigationCheckpoint("page2")
        .navigationTitle("Page 2")
    }
}

struct HomePage3View: View {
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section("Navigation Actions") {
                NavigationLink(value: HomeDestinations.pageN(66)) {
                    Text("Link to Home Page 66!")
                }
                Button("Button Push to Home Page 77") {
                    navigator.push(HomeDestinations.pageN(77))
                }
            }
            ContentSheetSection()
            ContentPopSection()
        }
        .navigationTitle("Page 3")
    }
}

struct HomePageNView: View {
    let number: Int
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section("Navigation Actions") {
                Button("Button Push to Home Page 88") {
                    navigator.push(HomeDestinations.pageN(88))
                }
            }
            ContentSheetSection()
            ContentPopSection()
        }
        .navigationTitle("Page \(number)")
    }
}

struct NestedHomeContentView: View {
    var body: some View {
        ManagedNavigationStack {
            HomeContentView(name: "Nested Navigation")
                .navigationDestination(HomeDestinations.self)
        }
    }
}

#Preview {
    RootHomeView()
}
