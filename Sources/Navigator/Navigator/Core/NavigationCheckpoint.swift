//
//  NavigationCheckpoint.swift
//  Navigator
//
//  Created by Michael Long on 11/20/24.
//

import SwiftUI

/// NavigationCheckpoints provide named checkpoints in the navigation tree.
///
/// Navigators know how to pop and/or dismiss views in order to return a previously defined checkpoint.
/// ### Setting Checkpoints
/// Setting a checkpoint is easy.
/// ```swift
/// struct RootHomeView: View {
///     var body: some View {
///         ManagedNavigationStack {
///             HomeContentView(title: "Home Navigation")
///                 .navigationDestination(HomeDestinations.self)
///                 .navigationCheckpoint(.home)
///         }
///     }
/// }
/// ```
/// ### Returning
/// As is returning to one.
/// ```swift
/// Button("Cancel") {
///     navigator.returnToCheckpoint(.home)
/// }
/// ```
/// This works even if the checkpoint is in a parent Navigator.
/// ### Defining Checkpoints
/// While checkpoint names can be simple strings, it's usually better to predefine them as shown below.
/// ```swift
/// extension NavigationCheckpoint {
///     public static let home: NavigationCheckpoint = "myApp.home"
///     public static let page2: NavigationCheckpoint = "myApp.page2"
///     public static let settings: NavigationCheckpoint = "myApp.settings"
/// }
/// ```
/// Using the same checkpoint name more than once in the same navigation tree isn't recommended.
public struct NavigationCheckpoint: Equatable, ExpressibleByStringLiteral, Hashable, Sendable {

    public let name: String

    internal let identifier: String?
    internal let index: Int

    public init(stringLiteral value: String) {
        self.name = value
        self.identifier = nil
        self.index = 0
    }

    public init(name: String, identifier: String? = nil) {
        self.name = name
        self.identifier = identifier
        self.index = 0
    }

    internal init(name: String, identifier: String?, index: Int) {
        self.name = name
        self.identifier = identifier
        self.index = index
    }

    public var unique: NavigationCheckpoint {
        let id = UUID().uuidString
        return .init(name: self.name + "." + id, identifier: id, index: index)
    }

    internal func setting(index: Int) -> NavigationCheckpoint {
        guard self.index == 0 else {
            return self
        }
        return NavigationCheckpoint(name: name, identifier: identifier, index: index)
    }

    internal func setting<T>(type: T.Type) -> NavigationCheckpoint {
        NavigationCheckpoint(name: name + "(\(String(describing: type)))", identifier: identifier, index: index)
    }

    internal func setting(identifier: String?) -> NavigationCheckpoint {
        NavigationCheckpoint(name: name, identifier: identifier, index: index)
    }

    public static func == (lhs: NavigationCheckpoint, rhs: NavigationCheckpoint) -> Bool {
        lhs.name == rhs.name && lhs.identifier == rhs.identifier
    }

}

extension NavigationCheckpoint: Codable {

    // Coding keys for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case name
        case index
    }

    // Custom encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(index, forKey: .index)
    }

    // Custom decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.identifier = nil
        self.index = try container.decode(Int.self, forKey: .index)
    }

}

extension Navigator {

    /// Returns to a named checkpoint in the navigation system.
    ///
    /// This function will pop and/or dismiss intervening views as needed.
    /// ```swift
    /// Button("Cancel") {
    ///     navigator.returnToCheckpoint(.home)
    /// }
    /// ```
    @MainActor
    public func returnToCheckpoint(_ checkpoint: NavigationCheckpoint) {
        state.returnToCheckpoint(checkpoint)
    }

    /// Returns to a named checkpoint in the navigation system, passing value to that checkpoint's completion handler.
    ///
    /// This function will pop and/or dismiss intervening views as needed.
    @MainActor
    public func returnToCheckpoint<T: Hashable>(_ checkpoint: NavigationCheckpoint, value: T?) {
        state.returnToCheckpoint(checkpoint, value: value)
    }

    /// Allow the code to determine if the checkpoint has been set and is known to the system.
    public nonisolated func canReturnToCheckpoint(_ checkpoint: NavigationCheckpoint) -> Bool {
        state.canReturnToCheckpoint(checkpoint)
    }

    internal func addCheckpoint(_ checkpoint: NavigationCheckpoint) {
        state.addCheckpoint(checkpoint)
    }

}

extension NavigationState {

    // Most of the following code does recursive data manipulation best performed on the state object itself.

    internal func find(_ checkpoint: NavigationCheckpoint) -> (NavigationState, NavigationCheckpoint)? {
        if let found = checkpoints[checkpoint.name] {
            return (self, found)
        }
        return parent?.find(checkpoint)
    }

    internal func returnToCheckpoint(_ checkpoint: NavigationCheckpoint) {
        guard let (navigator, found) = find(checkpoint) else {
            log(type:.warning, "Navigator checkpoint not found in current navigation tree: \(checkpoint.name)")
            return
        }
        log("Navigator returning to checkpoint: \(checkpoint.name)")
        _ = navigator.dismissAll()
        _ = navigator.pop(to: found.index)
    }

    internal func returnToCheckpoint<T: Hashable>(_ checkpoint: NavigationCheckpoint, value: T) {
        let checkpoint = checkpoint.setting(type: T.self)
        guard let (navigator, found) = find(checkpoint) else {
            log(type:.warning, "Navigator checkpoint value handler not found: \(checkpoint.name)")
            return
        }
        log("Navigator returning to checkpoint: \(checkpoint.name) value: \(value)")
        // send value to specific receive handler
        if let identifier = found.identifier {
            let values = NavigationSendValues(navigator: Navigator(state: self), identifier: identifier, value: value)
            publisher.send(values)
        }
        // return to sender
        _ = navigator.dismissAll()
        _ = navigator.pop(to: found.index)
    }

    internal nonisolated func canReturnToCheckpoint(_ checkpoint: NavigationCheckpoint) -> Bool {
        guard let (navigator, found) = find(checkpoint) else {
            return false
        }
        return navigator.isPresenting || found.index < navigator.path.count
    }

    internal func addCheckpoint(_ checkpoint: NavigationCheckpoint) {
        if let found = checkpoints[checkpoint.name] {
            if checkpoint.identifier != found.identifier {
                checkpoints[checkpoint.name] = checkpoint.setting(identifier: checkpoint.identifier)
            }
            return
        }
        let checkpoint = checkpoint.setting(index: path.count)
        checkpoints[checkpoint.name] = checkpoint.setting(index: path.count)
        log("Navigator \(id) adding checkpoint: \(checkpoint.name)")
    }

    internal func cleanCheckpoints() {
        checkpoints = checkpoints.filter {
            guard $1.index <= path.count else {
                log("Navigator \(id) removing checkpoint: \($1.name)")
                return false
            }
            return true
        }
    }

}

extension View {

    /// Establishes a named checkpoint in the navigation system.
    ///
    /// Navigators know how to pop and/or dismiss views in order to return to this checkpoint when needed.
    /// ```swift
    /// struct RootHomeView: View {
    ///     var body: some View {
    ///         ManagedNavigationStack {
    ///             HomeContentView(title: "Home Navigation")
    ///                 .navigationDestination(HomeDestinations.self)
    ///                 .navigationCheckpoint(.home)
    ///         }
    ///     }
    /// }
    /// ```
    /// Here, returning to the checkpoint named `.home` will return to the root view in this navigation stack.
    public func navigationCheckpoint(_ checkpoint: NavigationCheckpoint, position: Int = 0) -> some View {
        self.modifier(NavigationCheckpointModifier(checkpoint: checkpoint.setting(index: position)))
    }

    /// Establishes a navigation checkpoint with a completion handler.
    public func navigationCheckpoint<T: Hashable>(
        _ checkpoint: NavigationCheckpoint,
        position: Int = 0,
        completion: @escaping (T) -> Void
    ) -> some View {
        self.modifier(NavigationCheckpointValueModifier(checkpoint: checkpoint.setting(index: position), completion: completion))
    }

    /// Declarative `returnToCheckpoint` modifier.
    ///
    /// Just set the checkpoint value to which you want to return.
    /// ```swift
    /// Button("Return To Home") {
    ///     checkpoint = .home
    /// }
    /// .navigationReturnToCheckpoint(trigger: $checkpoint)
    /// ```
    /// Note that executing the checkpoint action will reset the bound value back to nil when complete.
    public func navigationReturnToCheckpoint(_ checkpoint: Binding<NavigationCheckpoint?>) -> some View {
        self.modifier(NavigationReturnToCheckpointModifier(checkpoint: checkpoint))
    }

    /// Declarative `returnToCheckpoint` modifier fired by a trigger.
    ///
    /// Just set the checkpoint value to which you want to return.
    /// ```swift
    /// Button("Return To Home") {
    ///     triggerReturn.toggle()
    /// }
    /// .navigationReturnToCheckpoint(trigger: $triggerReturn, checkpoint: .home)
    /// ```
    /// Note that executing the checkpoint action will reset the trigger value back to false when complete.
    public func navigationReturnToCheckpoint(trigger: Binding<Bool>, checkpoint: NavigationCheckpoint) -> some View {
        self.modifier(NavigationReturnToCheckpointTriggerModifier(trigger: trigger, checkpoint: checkpoint))
    }

}

private struct NavigationCheckpointModifier: ViewModifier {
    @Environment(\.navigator) var navigator: Navigator
    internal let checkpoint: NavigationCheckpoint
    func body(content: Content) -> some View {
        content
            .modifier(WrappedModifier(checkpoint: checkpoint, navigator: navigator))
    }
    // Wrapped modifier allows parent environment variables can be extracted and passed to navigator.
    struct WrappedModifier:  ViewModifier {
        init(checkpoint: NavigationCheckpoint, navigator: Navigator) {
            navigator.addCheckpoint(checkpoint)
        }
        func body(content: Content) -> some View {
            content
        }
    }
}

private struct NavigationCheckpointValueModifier<T: Hashable>: ViewModifier {
    @State internal var checkpoint: NavigationCheckpoint
    internal let completion: (T) -> Void
    @Environment(\.navigator) private var navigator: Navigator
    init(
        checkpoint: NavigationCheckpoint,
        completion: @escaping (T) -> Void
    ) {
        self.checkpoint = checkpoint
            .setting(type: T.self)
            .setting(identifier: checkpoint.identifier ?? UUID().uuidString)
        self.completion = completion
    }
    func body(content: Content) -> some View {
        content
            .onReceive(navigator.state.publisher) { values in
                if let value: T = values.consume(checkpoint.identifier) {
                    navigator.log("Navigator processing checkpoint: \(checkpoint.name) value: \(value)")
                    completion(value)
                    values.resume(.auto)
                }
            }
            .navigationCheckpoint(checkpoint)
    }
}

private struct NavigationReturnToCheckpointModifier: ViewModifier {
    @Binding internal var checkpoint: NavigationCheckpoint?
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: checkpoint) { checkpoint in
                if let checkpoint {
                    navigator.returnToCheckpoint(checkpoint)
                    self.checkpoint = nil
                }
            }
    }
}

private struct NavigationReturnToCheckpointTriggerModifier: ViewModifier {
    @Binding internal var trigger: Bool
    internal let checkpoint: NavigationCheckpoint
    @Environment(\.navigator) internal var navigator: Navigator
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { trigger in
                if trigger {
                    navigator.returnToCheckpoint(checkpoint)
                    self.trigger = false
                }
            }
    }
}
