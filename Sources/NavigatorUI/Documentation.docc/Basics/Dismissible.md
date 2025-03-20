# Dismissible Views

Understanding dismissible views and their role in application navigation and deep linking.

## Overview

How does a presented view dismiss itself? How does a parent view dismiss its children when needed?

What if we don't have access to the state that triggered the original presentation?

And what about deep-linking? Linking to a known location an application is easy when an application is launched, but what if the application's been running for a while? What if the user's presented a sheet or fullscreen cover view and is in the middle of doing something else?

How do you return to a known state in the application? 

And what if I want to *prevent* such things from happening if, say, I'm in the middle of a banking transaction?

All of these problems are solved in Navigator by using managed *dismissible* views.

## Dismissible Views

So what's a dismissible view? 

Well, the easy answer would be that a dismissible view is a presented view that can be dismissed... and that's true. But a better definition for our
purposes is that a dismissible view is a *presented* view that Navigator *knows how to dismiss*.

### The Navigation Tree

As mentioned in <doc:NavigationTree>, Navigator builds a navigation tree of Navigators within your application, starting from the application root, into each ``ManagedNavigationStack``, and from there into every presented view wrapped in a ``ManagedPresentationView``.

Think of a TabView where each tab has it's own ``ManagedNavigationStack``. Each managed stack and associated Navigator is a child of the application root.

And if a tab presents a view via a sheet or cover, that view is *also* a node in the navigation tree. 

The result is a tree of navigation stacks (and paths), presented views that can have their own stacks and paths and presented views, and so on, and so on, as needed.

This tree can be walked by Navigator and the application at will, allowing the dismissal of presented views from child or root, without the need for passed bindings or closures.

### Checkpoints

Keep in mind that dismissal is largely imperative and if you're in a child view a better solution is returning to previously established <doc:Checkpoints>.

But that doesn't help if you're deep linking of if you're engaged in cross-module navigation, so let's be about it.

## Operations

So here are some of Navigator's "dismiss" operations, along with examples and use cases.

### • Dismiss

Dismisses the currently presented ManagedNavigationStack.
```swift
Button("Dismiss") {
    navigator.dismiss()
}
```
Note that unlike Apple's dismiss environment variable, Navigator's dismiss function doesn't "pop" the current view on the navigation path.

It exists *solely* to dismiss the currently presented view from *within* the
currently presented view.

### • DismissPresentedViews

Dismisses any presented sheet or fullScreenCover views presented by this Navigator using `navigator.navigate(to:)`.
```swift
Button("Dismiss Presented Views") {
    navigator.dismissPresentedViews()
}
```
This is used in the parent view to dismiss its children, effectively the opposite of `dismiss()`.

### • DismissAnyChildren

Dismisses *any* `ManagedNavigationStack` or `ManagedPresentationView` presented by this Navigator or by any child of this Navigator in the current 
navigation tree.
```swift
Button("Dismiss Any Children") {
    navigator.dismissAnyChildren()
}
```
Returns true if a dismissal occurred, false otherwise.

This is used in the parent view to dismiss its children, effectively the opposite of `dismiss()`.

### • DismissAny

Returns to the root Navigator and dismisses *any* `ManagedNavigationStack` or `ManagedPresentationView` presented anywhere in the navigation tree.
```swift
Button("Dismiss Any") {
    try? navigator.dismissAny()
}
```
Returns true if a dismissal occurred, false otherwise.

This functionality is used extensively in deep linking and cross-module navigation in order to clear any presented views prior to taking the user
elsewhere in the application.

"I don't care what the user is doing. Shut it down."

It dismisses anything. Anywhere.

Note that this call can throw and fail if navigation is locked.

## Locking Navigation

As mentioned earlier, what if I want to *prevent* dismissal from happening? 

What if, for example, I presented a sheet to pay bils and I don't want a deep link to interrupt my flow?

Just add the `navigationLocked` modifier to the presented view.
```swift
MyTransactionView()
    .navigationLocked()
```
You can still dismiss your view, and a parent can still dismiss its child, but the global `dismissAny` action will fail and throw an error.

When the view containing the navigation lock is dismissed, the global lock is cleared automatically.

## Modifiers

Dismissal can also be purely state driven using the following modifiers.
```swift
// dismiss
.navigationDismiss(trigger: $dismiss1)

// dismiss presented views
.NavigationDismissPresentedViews(trigger: $dismiss2)

// dismiss any children
.navigationDismissAnyChildren(trigger: $dismiss3)

// dismiss any
.navigationDismissAny(trigger: $dismiss4)
```
Binding must be a boolean value and toggled to true to trigger the dismissal. Bound value will be reset to false afterwards.

## Checkpoints

Keep in mind that dismissal is largely imperative and fragile. It depends on knowledge of how the app is constructed and how the views are presented.

So, again, if you're in a child view a better solution is returning to a previously established checkpoint (<doc:Checkpoints>).

### Internals

That said, you should be aware that checkpoint behavior is based in part on dismissible views!
```swift
internal func returnToCheckpoint<T>(_ checkpoint: NavigationCheckpoint<T>) {
    guard let (navigator, found) = find(checkpoint) else {
        return
    }
    ...
    _ = navigator.dismissAnyChildren()
    _ = navigator.pop(to: found.index)
    ...
}
```
This is just one example of how Navigator's core functionality is used to enable more complex behaviors.
