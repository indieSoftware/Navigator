# Navigator

Managed Navigation for SwiftUI.

## Introduction

Navigator provides SwiftUI with a simple, cohesive navigation layer based on NavigationStack. 

It supports...

* Separation of concerns. 
* Simple and easy navigation linking and presentation of views.
* Easily returning to a specific spot in the navigation tree via navigation checkpoints.
* Application deep linking and internal application navigation.
* Imperative, programatic navigation and control.
* Navigation state restoration.

Navigator is written entirely in Swift and SwiftUI, and supports iOS 16 and above.

## The Code

### Defining Navigation Destinations
Destinations are typically just a simple list of enumerated values.
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
This can be done via using a standard SwiftUI `NavigationLink(value:label:)` view.
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
```

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
