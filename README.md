# Navigator

Managed Navigation for SwiftUI.

## Introduction

Navigator provides SwiftUI with a simple, cohesive navigation layer based on NavigationStack. 

It supports...

* Separation of concerns. 
* Simple and easy navigation linking and presentation of views.
* Easily returning to a specific spot in the navigation tree via navigation checkpoints.
* Returning callback values via navigation checkpoints.
* External deep linking and internal application navigation via navigation send.
* Imperative, programatic navigation and control.
* Navigation state restoration.

Navigator is written entirely in Swift and SwiftUI, and supports iOS 16 and above.

## The Code

### Defining Navigation Destinations
Destinations (or routes) are typically just a simple list of enumerated values.
```swift
public enum HomeDestinations {
    case page2
    case page3
    case pageN(Int)
}
```
Along with an extension that provides the correct view for a specific case.
```swift
extension HomeDestinations: NavigationDestination {
    public var body: some View {
        switch self {
        case .page2:
            HomePage2View()
        case .page3:
            HomePage3View()
        case .pageN(let value):
            HomePageNView(number: value)
        }
    }
}
```
Note how associated values can be used to pass parameters to views as needed.

### Using Navigation Destinations
Navigation Destinations can be dispatched using a standard SwiftUI `NavigationLink(value:label:)` view.
```swift
NavigationLink(value: HomeDestinations.page3) {
    Text("Link to Home Page 3!")
}
```
Or imperatively by asking a Navigator to perform the desired action.
```swift
Button("Button Navigate to Home Page 55") {
    navigator.navigate(to: HomeDestinations.pageN(55))
}
Button("Present Home Page 55 Via Sheet") {
    navigator.navigate(to: HomeDestinations.pageN(55), method: .sheet)
}
```
Note that destinations dispatched via NavigationLink will always push onto the NavigationStack. That's just how SwiftUI works.

### Registering Navigation Destinations
Like traditional `NavigationStack` destination types, `NavigationDestination` types need to be registered with the enclosing
navigation stack in order for standard `NavigationLink(value:label:)` transitions to work correctly.

But since each `NavigationDestination` already defines the view to be provided, registering destination types can be done
using a simple one-line view modifier.
```swift
ManagedNavigationStack {
    HomeView()
        .navigationDestination(HomeDestinations.self)
}
```
This also makes using the same destination type with more than one navigation stack a lot easier.

### Navigation Methods
`NavigationDestination` can also be extended to provide a distinct ``NavigationMethod`` for each enumerated type.
```swift
extension HomeDestinations: NavigationDestination {
    public var method: NavigationMethod {
        switch self {
        case .page3:
            .sheet
        default:
            .push
        }
    }
}
```
In this case, should `navigator.navigate(to: HomeDestinations.page3)` be called, Navigator will automatically present that view in a
sheet. All other views will be pushed onto the navigation stack.

## Documentation

A single README file barely scratches the surface. Fortunately, Navigator is throughly documented. 

Current DocC documentation can be found in the project.

## Installation

Navigator supports the Swift Package Manager.

Or download the source files and add the Navigator folder to your project.

Note that the current version of Navigator requires Swift 5.10 minimum and that the minimum version of iOS currently supported with this release is iOS 16.

## Discussion Forum

Discussion and comments on Navigator can be found in [Discussions](https://github.com/hmlongco/Navigator/discussions). Go there if you have something to say or if you want to stay up to date.

## License

Navigator is available under the MIT license. See the LICENSE file for more info.

## Sponsor Navigator!

If you want to support my work on Navigator, Factory and my other open source projects, consider a [GitHub Sponsorship](https://github.com/sponsors/hmlongco)! Many levels exist for increased support and even for mentorship and company training. 

Or you can just buy me a cup of coffee!

## Author

Navigator is designed, implemented, documented, and maintained by [Michael Long](https://www.linkedin.com/in/hmlong/), a Lead iOS Software Engineer and a Top 1,000 Technology Writer on Medium.

* LinkedIn: [@hmlong](https://www.linkedin.com/in/hmlong/)
* Medium: [@michaellong](https://medium.com/@michaellong)
* BlueSky: [@hmlongco](https://bsky.app/profile/hmlongco.bsky.social)

Michael was also one of Google's [Open Source Peer Reward](https://opensource.googleblog.com/2021/09/announcing-latest-open-source-peer-bonus-winners.html) winners in 2021 for his work on Resolver.

## Additional Resources

* [Factory](https://hmlongco.github.io/Factory/)
