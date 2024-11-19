//
//  SettingsDestinations.swift
//  Nav5
//
//  Created by Michael Long on 11/18/24.
//

import Navigator
import SwiftUI

public enum SettingsDestinations {
    case page2
    case page3
}

extension SettingsDestinations: NavigationDestinations {
    public var body: some View {
        switch self {
        case .page2:
            Page2SettingsView()
        case .page3:
            Page3SettingsView()
        }
    }
}
