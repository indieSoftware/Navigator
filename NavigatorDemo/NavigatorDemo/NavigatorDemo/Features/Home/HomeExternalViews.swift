//
//  HomeExternalViews.swift
//  NavigatorDemo
//
//  Created by Michael Long on 9/28/25.
//

import NavigatorUI
import SwiftUI

nonisolated public enum HomeExternalViews: NavigationProvidedDestination {
    case external
}

// old way using DI system
extension HomeExternalViews: NavigationViews {}
