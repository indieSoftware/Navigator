//
//  MockDestination.swift
//  Navigator
//
//  Created by zzmasoud on 2/16/25.
//

import SwiftUI
import Navigator

enum MockDestination: String, NavigationDestination {
    case screen1
    case screen2
    case screen3
    
    var id: String {
        return self.rawValue
    }
    
    @ViewBuilder
    var view: some View {
        Text("Mock View")
    }
    
    var method: NavigationMethod {
        .push
    }
}
