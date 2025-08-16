//
//  LoadingDestinations.swift
//  NavigatorDemo
//
//  Created by Michael Long on 3/9/25.
//

import NavigatorUI
import SwiftUI

nonisolated public enum LoadingDestinations: Int, Codable, NavigationDestination {

    case external

    public var body: some View {
        switch self {
        case .external:
            SettingsExternalView()
        }
    }

}
