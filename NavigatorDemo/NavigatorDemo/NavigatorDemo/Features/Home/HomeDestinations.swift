//
//  TestPage.swift
//  Nav5
//
//  Created by Michael Long on 11/10/24.
//

import NavigatorUI
import SwiftUI

public enum HomeDestinations: Codable {

    case home(String)
    case page2
    case page3
    case pageN(Int)
    case external
    case presented1
    case presented2

}

extension HomeDestinations: NavigationDestination {

    // Illustrates external mapping of destination type to views. See Settings for simple mapping.
    public var body: some View {
        HomeDestinationsView(select: self)
    }

}

// External view mapping allows access to environment variables, in this case homeDependencies.
internal struct HomeDestinationsView: View {

    // Selected destination to display
    let select: HomeDestinations

    // Obtain home dependency resolver
    @Environment(\.homeDependencies) var resolver

    // Standard view body
    var body: some View {
        switch select {

        case .home(let title):
            // Demonstrates method of injecting dependencies and building fully constructed view models
            HomeContentView(viewModel: HomeContentViewModel(resolver: resolver, title: title))

        case .page2:
            // Demonstrates injecting dependencies by asking injection system to provide fully constructed view model
            HomePage2View(viewModel: resolver.homePage2ViewModel)

        case .page3:
            HomePage3View(initialValue: 66)

        case .pageN(let value):
            // Demonstrates passing dependency resolver to view and letting it do what's needed.
            HomePageNView(resolver: resolver, number: value)

        case .external:
            // Demonstrates getting view itself from unknown source
            resolver.homeExternalViewProvider.view(for: .external)

        case .presented1:
            // Demonstrates internally presented view via method
            NestedHomeContentView(title: "Via Sheet")

        case .presented2:
            // This presented view can not be globally dismissed via navigation action, deep links, etc.
            NestedHomeContentView(title: "Via Cover")
                .navigationLocked()

        }
    }
}

extension HomeDestinations {

    // not required but shows possibilities in predefining navigation destination types
    public var method: NavigationMethod {
        switch self {
        case .home, .page2, .page3, .pageN, .external:
            .push
        case .presented1:
            .sheet
        case .presented2:
            .cover
        }
    }
    
}
