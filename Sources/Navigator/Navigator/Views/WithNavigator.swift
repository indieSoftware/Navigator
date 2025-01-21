//
//  WithNavigator.swift
//  Navigator
//
//  Created by Michael Long on 1/21/25.
//

import SwiftUI

public struct WithNavigator<Content: View>: View {

    @Environment(\.navigator) private var navigator

    internal let content: (Navigator) -> Content

    public init(@ViewBuilder content: @escaping (Navigator) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(navigator)
    }
    
}
