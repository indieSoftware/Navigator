//
//  ContentView.swift
//  Nav5
//
//  Created by Michael Long on 11/10/24.
//

import Navigator
import SwiftUI

extension NavigationCheckpoint {
    public static let home: NavigationCheckpoint = "home"
    public static let page2: NavigationCheckpoint = "page2"
    public static let settings: NavigationCheckpoint = "settings"
}

struct RootHomeView: View {
    var body: some View {
        ManagedNavigationStack(scene: "home") {
            HomeContentView(title: "Home Navigation")
                .navigationCheckpoint(.home)
                .navigationDestination(HomeDestinations.self)
                .onNavigationReceive { (destination: HomeDestinations, navigator) in
                    navigator.navigate(to: destination)
                    return .auto
                }
//                .onNavigationReceive { (destination: HomeDestinations, navigator) in
//                    navigator.navigate(to: destination)
//                    return .auto
//                }
        }
    }
}

class HomeContentViewModel: ObservableObject {
    let title: String
    init(dependencies: HomeDependencies, title: String) {
        self.title = title + " " + dependencies.networker().load()
    }
}

struct HomeContentView: View {
    let title: String
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

            SendResumeAuthenticatedView()
            ContentSheetSection()
            ContentPopSection()
        }
        .navigationTitle(title)
    }
}

class HomePage2ViewModel: ObservableObject {
    let title: String
    init(dependencies: HomeDependencies) {
        title = "Page 2 " + dependencies.networker().load()
    }
}

struct HomePage2View: View {
    @StateObject var viewModel: HomePage2ViewModel
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
        .navigationCheckpoint(.page2)
        .navigationTitle(viewModel.title)
    }
}

struct HomePage3View: View {
    let initialValue: Int
    @Environment(\.navigator) var navigator: Navigator
    var body: some View {
        List {
            Section("Navigation Actions") {
                NavigationLink(value: HomeDestinations.pageN(initialValue)) {
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
    var title: String
    var body: some View {
        ManagedNavigationStack {
            // Demonstrates using destinations to build root views that may have dependencies.
            HomeDestinations.home(title).view
                .navigationDestination(HomeDestinations.self)
            }
    }
}

#Preview {
    RootHomeView()
}
