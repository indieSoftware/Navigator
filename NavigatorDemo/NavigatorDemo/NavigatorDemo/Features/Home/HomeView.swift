//
//  ContentView.swift
//  Nav5
//
//  Created by Michael Long on 11/10/24.
//

import Navigator
import SwiftUI

class HomeRootViewModel: ObservableObject {
    @Published var id = UUID()
    internal let resolver: HomeDependencies
    internal let logger: any Logging
    init(resolver: HomeDependencies) {
        self.resolver = resolver
        self.logger = resolver.logger()
        logger.log("HomeRootViewModel initialized \(id)")
    }
    deinit {
        logger.log("HomeRootViewModel deinit \(id)")
    }
}

//extension HomeDependencies {
//    var homeRootViewModel: HomeRootViewModel {
//        HomeRootViewModel(dependencies: self)
//    }
//}

struct HomeRootView: View {
    @StateObject var viewModel: HomeRootViewModel
    var body: some View {
        ManagedNavigationStack(scene: RootTabs.home.id) {
            HomeContentView(resolver: viewModel.resolver, title: "Home Navigation")
                .navigationCheckpoint(.home)
                .navigationDestination(HomeDestinations.self)
                .onNavigationReceive { (destination: HomeDestinations, navigator) in
                    navigator.navigate(to: destination)
                    return .auto
                }
        }
    }
}

class HomeContentViewModel: ObservableObject {
    let title: String
    init(resolver: HomeDependencies, title: String) {
        self.title = title
    }
}

struct HomeContentView: View {
    @StateObject private var viewModel: HomeContentViewModel
    init(resolver: HomeDependencies, title: String) {
        self._viewModel = .init(wrappedValue: .init(resolver: resolver, title: title))
    }
    @Environment(\.navigator) var navigator
    var body: some View {
        List {
            Section("Navigation Actions") {
                NavigationLink(value: HomeDestinations.page2) {
                    Text("Link to Home Page 2!")
                }
                NavigationLink(value: HomeDestinations.pageN(44)) {
                    Text("Link to Home Page 44!")
                }
                NavigationLink(value: HomeDestinations.external) {
                    Text("Link to External View!")
                }
                Button("Button Navigate to Home Page 55") {
                    navigator.navigate(to: HomeDestinations.pageN(55))
                }
            }
            Section("Send Actions") {
                Button("Send Home Page 2, 3") {
                    navigator.send(values: [
                        HomeDestinations.page2,
                        HomeDestinations.page3,
                    ])
                }
            }
            ContentRoutingSection()
            SendResumeAuthenticatedView()
            ContentSheetSection()
            ContentCheckpointSection()
            ContentPopSection()
        }
        .navigationTitle(viewModel.title)
    }
}

class HomePage2ViewModel: ObservableObject {
    let title: String
    init(dependencies: HomeDependencies) {
        title = "Page 2 " + dependencies.loader().load()
        print("HomePage2ViewModel initialized \(ObjectIdentifier(self))")
    }
    deinit {
        print("HomePage2ViewModel deinit \(ObjectIdentifier(self))")
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
            Section("Find") {
                Button("Clear Home Via Find") {
                    navigator.named("home")?.popAll()
                }
                Button("Clear Settings With Action") {
                    // Roundabout way of doing this, primarily for testing
                    navigator.perform(action: .with(navigator: RootTabs.settings.id) {
                        $0.popAll()
                    })
                }
            }
            ContentSheetSection()
            ContentCheckpointSection()
            ContentPopSection()
        }
        .navigationCheckpoint(.page2)
//        .navigationCheckpoint(.page2, position: 1)
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
            ContentCheckpointSection()
            ContentPopSection()
        }
        .navigationTitle("Page 3")
    }
}

class HomePageNViewModel: ObservableObject {
    let number: Int
    let resolver: HomeDependencies
    init(resolver: HomeDependencies, number: Int) {
        self.resolver = resolver
        self.number = number
    }
}

struct HomePageNView: View {
    @StateObject private var viewModel: HomePageNViewModel
    @Environment(\.navigator) var navigator: Navigator
    init(resolver: HomeDependencies, number: Int) {
        self._viewModel = .init(wrappedValue: .init(resolver: resolver, number: number))
    }
    var body: some View {
        List {
            Section("Send Actions") {
                Button("Send Home Page 2, 88, 99") {
                    navigator.send(values: [
                        NavigationAction.popAll(in: RootTabs.home.id),
                        HomeDestinations.page2,
                        HomeDestinations.pageN(88),
                        HomeDestinations.pageN(99)
                    ])
                }
                Button("Route To Settings Page 2") {
                    viewModel.resolver.homeExternalRouter().route(to: .settingsPage2)
                }
            }
            ContentSheetSection()
            ContentCheckpointSection()
            ContentPopSection()
        }
        .navigationTitle("Page \(viewModel.number)")
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

#if DEBUG
#Preview {
    // Demonstrates using destinations to build root views that may have dependencies.
    // Also mocking network call results for these types.
    RootTabs.home()
        .setAuthenticationRoot()
        .environment(\.homeDependencies, MockHomeResolver()
            .mock { "(M5)" }
            .mock { 222 }
        )
}
#endif
