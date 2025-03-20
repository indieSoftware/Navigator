//
//  AuthenticationService.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/11/25.
//

import NavigatorUI
import SwiftUI

// Define a new action placeholder
extension NavigationAction {
    @MainActor static var authenticationRequired: NavigationAction = .empty
}

// Define our "authentication" view model
@MainActor
public class AuthenticationService: ObservableObject {

    @Published internal var authenticationDialogNeeded: Bool = false
    @Published internal var user: User?

    internal init() {
        setupAuthenticationRequired()
    }

    public var isAuthenticated: Bool { user != nil }

    public func authenticate() {
        guard !isAuthenticated else { return }
        authenticationDialogNeeded = true
    }

    public func authenticate(with user: User) {
        self.user = user
    }

    public func logout() {
        user = nil
    }

    internal func setupAuthenticationRequired() {
        // Setup authentication required handler for use by any deep linking navigation action
        NavigationAction.authenticationRequired = .init("authenticationRequired") { _ in
            // if already authenticated then return and allow immediate execution of remaining deep linking values
            if self.isAuthenticated {
                return .immediately
            }
            // otherwise request authentication
            self.authenticate()
            // and then tell Navigator to pause while we wait for that to occur
            return .pause
        }
    }

}

extension View {
    public func setAuthenticationRoot() -> some View {
        self.modifier(AuthenticationRootModifier())
    }
}

struct AuthenticationRootModifier: ViewModifier {

    @StateObject var authentication = AuthenticationService()
    @Environment(\.navigator) var navigator: Navigator

    func body(content: Content) -> some View {
        content
            .environmentObject(authentication)
            .alert(isPresented: $authentication.authenticationDialogNeeded) {
                Alert(
                    title: Text("Authentication Required"),
                    message: Text("Are you Michael Long?"),
                    primaryButton: .default(Text("Yes")) {
                        // I am me. Me say so.
                        authentication.authenticate(with: User(name: "Michael Long"))
                        // tell Navigator to resume with any deep linking values it might have paused
                        navigator.resume()
                    },
                    secondaryButton: .cancel {
                        // clear out any resumable values
                        navigator.cancelResume()
                    }
                )
            }
    }

}

public struct User {
    let name: String
}
