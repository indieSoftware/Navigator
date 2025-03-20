//
//  MockDestination.swift
//  Navigator
//
//  Created by zzmasoud on 2/16/25.
//

import SwiftUI
import NavigatorUI

enum MockDestination: String, NavigationDestination {
    case screen1
    case screen2
    case screen3
    
    nonisolated var id: String {
        return self.rawValue
    }
    
    @ViewBuilder
    var body: some View {
        Text("Mock View")
    }
    
    var method: NavigationMethod {
        .push
    }
}
