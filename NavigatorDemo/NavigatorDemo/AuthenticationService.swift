//
//  AuthenticationService.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/11/25.
//

import Navigator
import SwiftUI

// Define a new action placeholder
extension NavigationAction {
    @MainActor static var authenticationRequired: NavigationAction?
}

// Define our "authentication" view model
@MainActor
public class AuthenticationService: ObservableObject {

    @Published internal var authenticationNeeded: Bool = false
    @Published internal var user: User?

    internal init() {
        setupAuthenticationRequired()
    }

    public var isAuthenticated: Bool { user != nil }

    public func authenticate() {
        authenticationNeeded.toggle()
    }

    public func authenticated(with user: User) {
        self.user = user
    }

    public func logout() {
        user = nil
    }

    internal func setupAuthenticationRequired() {
        // Attach authentication handler for use by navigation action
        NavigationAction.authenticationRequired = .init("authorizing") { _ in
            if self.isAuthenticated {
                return .immediately
            }
            // request authentication
            self.authenticate()
            // tell Navigator to pause sending any further deep linking values while we wait
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
    @Environment(\.navigator) var navigator

    func body(content: Content) -> some View {
        content
            .environmentObject(authentication)
            .alert(isPresented: $authentication.authenticationNeeded) {
                Alert(
                    title: Text("Authentication Required"),
                    message: Text("Are you who you think you are?"),
                    primaryButton: .default(Text("Yes")) {
                        // I am me. Me say so.
                        authentication.authenticated(with: User(name: "Michael Long"))
                        // tell Navigator to resume with any deep linking values it might have paused
                        navigator.resume()
                    },
                    secondaryButton: .cancel()
                )
            }
    }

}

public struct User {
    let name: String
}
