//
//  NavigationModifiers.swift
//  Navigator
//
//  Created by Michael Long on 11/30/24.
//

import SwiftUI

extension View {

    public func navigate(to destination: Binding<(some NavigationDestination)?>) -> some View {
        self.modifier(NavigateToModifier(destination: destination, method: destination.wrappedValue?.method ?? .push))
    }

    public func navigate(to destination: Binding<(some NavigationDestination)?>, method: NavigationMethod) -> some View {
        self.modifier(NavigateToModifier(destination: destination, method: method))
    }

    public func navigate(trigger: Binding<Bool>, destination: some NavigationDestination) -> some View {
        self.modifier(NavigateTriggerModifier(trigger: trigger, destination: destination, method: destination.method))
    }

    public func navigate(trigger: Binding<Bool>, destination: some NavigationDestination, method: NavigationMethod) -> some View {
        self.modifier(NavigateTriggerModifier(trigger: trigger, destination: destination, method: method))
    }
    
}

private struct NavigateToModifier<T: NavigationDestination>: ViewModifier {
    @Binding internal var destination: T?
    internal let method: NavigationMethod
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: destination) { destination in
                if let destination {
                    navigator.navigate(to: destination, method: method)
                    self.destination = nil
                }
            }
    }
}

private struct NavigateTriggerModifier<T: NavigationDestination>: ViewModifier {
    @Binding internal var trigger: Bool
    let destination: T
    internal let method: NavigationMethod
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger {
                    navigator.navigate(to: destination, method: method)
                    self.trigger = false
                }
            }
    }
}
