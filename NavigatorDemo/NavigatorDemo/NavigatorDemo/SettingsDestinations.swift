//
//  SettingsDestinations.swift
//  Nav5
//
//  Created by Michael Long on 11/18/24.
//

import Navigator
import SwiftUI

public enum SettingsDestinations: Int, Codable {
    case page2
    case page3
    case sheet
    case external
}

extension SettingsDestinations: NavigationDestination {
    // Illustrates simple embedded mapping of destination type to views. See Home for more complex example.
    public var view: some View {
        switch self {
        case .page2:
            Page2SettingsView()
        case .page3:
            Page3SettingsView()
        case .sheet:
            SettingsSheetView()
                .navigationDismissible()
        case .external:
            SettingsExternalView()
        }
    }
    public var method: NavigationMethod {
        switch self {
        case .sheet:
            .sheet
        default:
            .push
        }
    }
}
