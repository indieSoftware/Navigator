//
//  RootSplitView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/25/25.
//

import Navigator
import SwiftUI

struct RootSplitView: View {
    var body: some View {
        NavigationSplitView {
            Text("")
        } content: {
            ManagedPresentationView {
                HomeContentView(title: "Home")
                    .navigationDestination(for: HomeDestinations.self) { destination in
                        destination()
                            .navigationCheckpoint(.home)
                            .navigationDestination(HomeDestinations.self)
                    }
                    .onNavigationReceive { (destination: HomeDestinations, navigator) in
                        navigator.navigate(to: destination)
                        return .auto
                    }
            }
        } detail: {
            ManagedNavigationStack {
                Text("hello")
                    .navigationDestination(HomeDestinations.self)
            }
        }
        .setAuthenticationRoot()
    }
}
