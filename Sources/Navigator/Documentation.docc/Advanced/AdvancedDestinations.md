# Advanced Destinations

Building NavigationDestinations that access the environment and other use cases 

## External NavigationDestinations

Earlier we demonstrated how to provide ``NavigationDestination`` types with a variable that returns the correct view for that type.
```swift
extension HomeDestinations: NavigationDestination {
    public var view: some View {
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
It's a powerful technique, but what if we can't construct a specific view without external dependencies or without accessing the environment? 

### Destination Views

Simple. Just delegate the view building to a standard SwiftUI view!
```swift
extension HomeDestinations: NavigationDestination {
    public var view: some View {
        HomeDestinationsView(destination: self)
    }
}

private struct HomeDestinationsView: View {
    let destination: HomeDestinations
    @Environment(\.coreDependencies) var resolver
    var body: some View {
        switch self {
        case .home:
            HomePageView(viewModel: HomePageViewModel(dependencies: resolver))
        case .page2:
            HomePage2View(viewModel: HomePage2ViewModel(dependencies: resolver))
        case .page3:
            HomePage3View(viewModel: HomePage3ViewModel(dependencies: resolver))
        case .pageN(let value):
            HomePageNView(dependencies: resolver, number: value)
        }
    }
}
```
In the above code, we obtain a `coreDependencies` resolver from the environment and then use it to construct our views
and view models.

### Passing Dependencies

Note that some of the examples expose the view model to the caller, and that's something I would generally argue against. The fact that a view has a view model (or not) is an implementation detail, and should be private to the view itself. 

But used in this fashion that external dependency is never exposed to the outside world, and that tends to mitigate the problem in my book. Sites  specify the desired view using its enumerated value, but they never see the view itself.

If that bothers you then one could simply pass the dependency resolver to the view itself, letting the view handle it as needed.
```swift
struct HomePageNView: View {
    @StateObject private var viewModel: HomePageNViewModel
    init(dependencies: HomeDependencies, number: Int) {
        self._viewModel = .init(wrappedValue: .init(dependencies: dependencies, number: number))
    }
    var body: some View {
        ...
    }
}
```

## NavigationDestinations within Views

This technique also allows us to construct and use fully functional views elsewhere in your view code. Consider.
```swift
struct RootHomeView: View {
    var body: some View {
        ManagedNavigationStack {
            HomeDestinations.home()
                .navigationDestination(HomeDestinations.self)
        }
    }
}
```
Calling the destination as a function obtains a fully resolved `HomePageView` and view model from `HomeDestinationsView`, 
complete and ready to go.

*See the 'DemoDependency.swift' file in the NavigatorDemo project for a possible dependency injection mechanism.*

## Custom Sheets using NavigationDestination
Let's demonstrate that again using a custom presentation mechanism with detents.

Only this time instead of evaluating the enumerated value directly we'll do the same using a destination variable.
```swift
struct CustomSheetView: View {
    @State private var showSettings: SettingsDestinations?
    var body: some View {
        List {
            Button("Present Page 2 via Sheet") {
                showSettings = .page2
            }
            Button("Present Page 2 via Sheet") {
                showSettings = .page3
            }
            .sheet(item: $showSettings) { destination in
                destination() // obtain view
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
```
Setting the variable passes the desired destination to the sheet closure via the `$showSettings` binding. Which again, evaluates the value and obtains a fully resolved view complete and ready for presentation.

## See Also

- <doc:Destinations>
