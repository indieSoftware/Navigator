//
//  SendResumeAuthenticatedView.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/1/25.
//

import Navigator
import SwiftUI

// Define a new action placeholder
extension NavigationAction {
    @MainActor static var authenticationRequired: NavigationAction?
}

// Define our "authentication" view model
@MainActor
class SendResumeAuthenticatedViewModel: ObservableObject {

    @Published var authenticate: Bool = false
    @Published var authenticated: Bool = false

    init() {
        setupAuthenticationRequired()
    }

    func setupAuthenticationRequired() {
        // Attach authentication handler for use by navigation actions
        NavigationAction.authenticationRequired = .init("authorizing") { _ in
            if self.authenticated {
                return .immediately
            }
            // show authentication dialog
            self.authenticate.toggle()
            // tell Navigator to pause sending any further deep linking values while we wait
            return .pause
        }
    }

}

struct SendResumeAuthenticatedView: View {

    @StateObject var viewModel = SendResumeAuthenticatedViewModel()
    @Environment(\.navigator) var navigator: Navigator

    var body: some View {
        Section("Send Pause/Resume Actions") {
            Button("Send Authentication Required, Page 77") {
                navigator.send(values: [
                    NavigationAction.authenticationRequired,
                    HomeDestinations.pageN(77)
                ])
            }
            .alert(isPresented: $viewModel.authenticate) {
                Alert(
                    title: Text("Authentication Required"),
                    message: Text("Are you who you think you are?"),
                    primaryButton: .default(Text("Yes")) {
                        // toggle authenticated flag
                        viewModel.authenticated.toggle()
                        // tell Navigator to resume with any deep linking values it might have paused
                        navigator.resume()
                    },
                    secondaryButton: .cancel()
                )
            }
            Button("Logout") {
                viewModel.authenticated = false
            }
            .disabled(!viewModel.authenticated)
        }
    }
}
