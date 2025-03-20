//
//  SendResumeAuthenticatedView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/1/25.
//

import NavigatorUI
import SwiftUI

struct SendResumeAuthenticatedView: View {

    @EnvironmentObject var authentication: AuthenticationService
    @Environment(\.navigator) var navigator: Navigator

    var body: some View {
        Section("Send Pause/Resume Actions") {
            Button("Send Authentication Required, Page 77") {
                navigator.send(
                    NavigationAction.dismissAny,
                    NavigationAction.authenticationRequired,
                    HomeDestinations.pageN(77)
                )
            }
            Button("Logout") {
                authentication.logout()
            }
            .disabled(!authentication.isAuthenticated)
        }
    }
}
