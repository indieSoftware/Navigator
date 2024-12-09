//
//  NavigationMethod.swift
//  Navigator
//
//  Created by Michael Long on 11/22/24.
//

/// Defines the desired presentation mechanism for a given `NavigationDestination`.
///
/// This can be pushing it onto a NavigationStack, presenting a sheet or fullScreenCover, or broadcasting a deep link through the application
/// via `navigation.send()`.
/// ```swift
/// Button("Button Navigate to Home Page 55") {
///     navigator.navigate(to: HomeDestinations.pageN(55), via: .fullScreenCover)
/// }
/// ```
/// `NavigationDestination` can also be extended to provide a distinct ``NavigationMethod`` for each enumerated type.
/// ```swift
/// extension HomeDestinations: NavigationDestination {
///     public var method: NavigationMethod {
///         switch self {
///         case .page3:
///             .sheet
///         default:
///             .push
///         }
///     }
/// }
/// ```
/// In this case, should `navigator.navigate(to: HomeDestinations.page3)` be called, Navigator will automatically present that view in a
/// sheet. All other views will be pushed onto the navigation stack.
///
/// > Important: When using `NavigationLink(value:label:)` the method will be ignored and SwiftUI will push
/// the value onto the navigation stack as it would normally.
public enum NavigationMethod {
    /// Pushes the destination onto the navigation stack path.
    case push

    /// Publishes the destination using `navigator.send()`.
    case send

    /// Displays the destination as a SwiftUI full screen cover.
    case cover

    /// Displays the destination as a SwiftUI sheet.
    case sheet
}
