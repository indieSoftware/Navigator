//
//  SendResumeAuthenticatedView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/1/25.
//

import Navigator
import SwiftUI

struct SendResumeAuthenticatedView: View {

    @Environment(\.navigator) var navigator: Navigator

    @State var authenticate: Bool = false
    @State var authenticated: Bool = false

    var body: some View {
        Section("Send Pause/Resume Actions") {
            Button("Send Authentication Required, Page 77") {
                navigator.send(values: [
                    AuthenticationRequired(),
                    HomeDestinations.pageN(77)
                ])
            }
            .onNavigationReceive { (_: AuthenticationRequired) in
                if authenticated {
                    return .immediately
                }
                // show authentication dialog
                authenticate.toggle()
                // tell Navigator to pause sending any further deep linking values while we wait
                return .pause
            }
            .alert(isPresented: $authenticate) {
                Alert(
                    title: Text("Authentication Required"),
                    message: Text("Are you who you think you are?"),
                    primaryButton: .default(Text("Yes")) {
                        // toggle authenticated flag
                        authenticated.toggle()
                        // tell Navigator to resume with any deep linking values it might have paused
                        navigator.resume()
                    },
                    secondaryButton: .cancel()
                )
            }
            Button("Logout") {
                authenticated = false
            }
            .disabled(!authenticated)
        }
    }
}

// Just a distinct type we can send...
struct AuthenticationRequired: Hashable {}
