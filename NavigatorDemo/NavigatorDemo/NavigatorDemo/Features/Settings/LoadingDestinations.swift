//
//  LoadingDestinations.swift
//  NavigatorDemo
//
//  Created by Michael Long on 3/9/25.
//

import NavigatorUI
import SwiftUI

public enum LoadingDestinations: Int, Codable {
    case external
}

extension LoadingDestinations: NavigationDestination {
    public var body: some View {
        switch self {
        case .external:
            SettingsExternalView()
        }
    }
//    public var method: NavigationMethod {
//        switch self {
//        case .external:
//            .sheet
//        }
//    }
}
