//
//  WithNavigator.swift
//  Navigator
//
//  Created by Michael Long on 11/20/24.
//

import SwiftUI

public struct WithNavigator<Content: View>: View {

    @Environment(\.navigator) private var navigator: Navigator
    private var content: (Navigator) -> Content
    
    public init(@ViewBuilder content: @escaping (Navigator) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(navigator)
    }
}
