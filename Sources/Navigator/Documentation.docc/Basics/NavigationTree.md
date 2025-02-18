# The Navigation Tree

To get the most out of Navigator, you need to understand the navigation tree where its Navigators live.

## Overview

NavigationStacks are managed by Navigators. Each ``ManagedNavigationStack`` used in your code creates its own ``Navigator`` and places an instance of that object into the environment for use by the views contained within it.

That allows *those* views to talk to *their* navigator.

One exception is the "root" Navigator that's usually configured and installed in the main application. That "root" passes the configuration along to its children and also allows for communication in instances like tabs where each tab has its own ManagedNavigationStack.

## The Navigation Tree

If you look at the code for `ManagedNavigationStack` (and `ManagedPresentationView`), you'll see where each one gets the current Navigator. That Navigator is then passed to the navigation state as its "parent", which in turn is used to build a navigation tree.
```swift
public struct ManagedPresentationView<Content: View>: View {
    @Environment(\.navigator) private var parent: Navigator
    @Environment(\.isPresented) private var isPresented
    ...
}
```
Every Navigator created within your application lives within that tree.

And that tree, in turn, is the key that unlocks much of Navigator's power and functionality. 

## TabViews

Here's a rough chart that illustrates the navigation tree of a running application that's using a TabView.

```
Application (Root Navigator)
TabView
-- Tab1: ManagedNavigationStack (New Navigator, Root as Parent)
-- Tab2: ManagedNavigationStack (New Navigator, Root as Parent)
-- Tab3: ManagedNavigationStack (New Navigator, Root as Parent)
---- Sheet: ManagedNavigationStack (New Navigator, Tab 3's as Parent)
------- Cover: ManagedNavigationStack (New Navigator, Presented Navigator is Parent)
```
Each tab wants to manage its own navigation, so each one has its own `ManagedNavigationStack` and its own `Navigator`.

This should make sense. If a view within tab 2 wants to push a new view onto the stack, then it needs to be talking to the right navigator. 

It doesn't want the view pushed onto tab 3's stack, does it?

That concept extends to presented sheets and covers as shown in tab 3. Each `ManagedNavigationStack` is installing its own Navigator into the tree, each one linked back to its parent.

Every `ManagedNavigationStack` creates its own `Navigator` that manages it.

*There are also ManagedPresentationViews, but that's another topic.*

## Example Code
So with all of the above in mind, consider the following example.
```swift
struct ContentView: View {
    @Environment(\.navigator) var parentNavigator
    var body: some View {
        ManagedNavigationStack { navigator in
            VStack {
                Button("Doesn't work as expected") {
                    parentNavigator.navigate(to: Destinations.second)
                }
                Button("Works as expected") {
                    navigator.navigate(to: Destinations.second)
                }
                SomeView()
            }
            .navigationDestination(Destinations.self)
        }
    }
}
```
Using an environment variable gets the current "parent" Navigator in the tree. (Root in this case.)

But `ManagedNavigationStack` creates and installs a *new* Navigator into the environment, one that knows how to talk to it. 

Which means that the code in the first button fails because it's talking to the wrong Navigator. If you want to manipulate the *current* NavigationStack and the designations that *it* knows about, you need to be talking to *its* Navigator. 

One way to do that is to use the Navigator passed to the ManagedNavigationStack's closure. That's shown in the second example.
```swift
ManagedNavigationStack { navigator in
    ...
}
```
Another is to use the environment. Wait. What?

## The Environment

Let's consider  `SomeView`.
```swift
struct SomeView: View {
    @Environment(\.navigator) var navigator
    var body: some View {
        Button("Also works as expected") {
            navigator.navigate(to: Destinations.second)
        }
    }
}
```
Here's we're also pulling from the environment, but in this case the code works as expected since *its* environment variable is reading the *current* environment variable, which is the one installed by the current `ManagedNavigationStack`.

## Walking The Tree

But what if I want to talk to a different Navigator?

That's more advanced. One can `find` a named Navigator in the tree, but generally you're going to want to consider other functionality offered by Navigator, like <doc:Checkpoints>, or deep linking using `send`.
