//
//  TestPage.swift
//  Nav5
//
//  Created by Michael Long on 11/10/24.
//

import Navigator
import SwiftUI

public enum HomeDestinations {
    case page2
    case page3
    case pageN(Int)
    case sheet
}

extension HomeDestinations: NavigationDestination {
    public var body: some View {
        switch self {
        case .page2:
            HomePage2View()
        case .page3:
            HomePage3View()
        case .pageN(let value):
            HomePageNView(number: value)
        case .sheet:
            NestedHomeContentView()
        }
    }
}
