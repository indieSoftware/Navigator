//
//  RootTabs.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/27/25.
//

import NavigatorUI
import SwiftUI

nonisolated enum RootTabs: Int, Codable, Identifiable, NavigationDestination {

    case home
    case examples
    case settings

    static var tabs: [RootTabs] {
        [.home, .examples, .settings]
    }

    static var sidebar: [RootTabs] {
        [.home, .settings]
    }

    var id: String {
        "\(self)"
    }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .examples:
            "Examples"
        case .settings:
            "Settings"
        }
    }

    var image: String {
        switch self {
        case .home:
            "house"
        case .examples:
            "list.star"
        case .settings:
            "gear"
        }
    }

    var body: some View {
        RootTabsViewBuilder(destination: self)
    }
    
}

private struct RootTabsViewBuilder: View {
    let destination: RootTabs
    @Environment(\.homeDependencies) var resolver
    var body: some View {
        switch destination {
        case .home:
            HomeRootView(viewModel: HomeRootViewModel(resolver: resolver))
        case .examples:
            ExamplesView()
        case .settings:
            SettingsRootView()
        }
    }
}

// following exploration into persisted state

//extension RootTabs: NavigationDestination {
//    var body: some View {
//        WithHomeDependencies { resolver in
//            RootTabsViewBuilder(destination: self, resolver: resolver)
//        }
//    }
//}
//
//private struct RootTabsViewBuilder: View {
//    let destination: RootTabs
//    @StateObject private var homeRootViewModel: HomeRootViewModel
//    init(destination: RootTabs, resolver: HomeDependencies) {
//        self.destination = destination
//        self._homeRootViewModel = .init(wrappedValue: .init())
//    }
//    var body: some View {
//        switch destination {
//        case .home:
//            HomeRootView(viewModel: homeRootViewModel)
//        case .settings:
//            SettingsRootView()
//        }
//    }
//}
//
//public struct WithHomeDependencies<Content: View>: View {
//    @Environment(\.homeDependencies) var resolver
//    @ViewBuilder let content: (HomeDependencies) -> Content
//    public var body: some View {
//        content(resolver)
//    }
//}

