//
//  NavigatorTests.swift
//  Navigator
//
//  Created by zzmasoud on 02/15/25.
//

import Testing
import Foundation
@testable import Navigator

struct NavigatorTests {
    // MARK: - Basic Navigation State Tests

    @Test func testNavigatorInitialization() {
        let config = NavigationConfiguration(restorationKey: "test")
        let navigator = Navigator(configuration: config)
        
        #expect(navigator.state.configuration?.restorationKey == "test")
        #expect(navigator.state.path.isEmpty)
        #expect(navigator.state.sheet == nil)
        #expect(navigator.state.cover == nil)
    }

    @Test func testNavigatorHierarchy() {
        let parentNavigator = Navigator(owner: .root, name: "parent")
        let childNavigator = Navigator(
            state: NavigationState(owner: .stack, name: "child"),
            parent: parentNavigator,
            isPresented: true
        )
        
        #expect(childNavigator.parent?.id == parentNavigator.id)
        #expect(childNavigator.root.id == parentNavigator.id)
        #expect(childNavigator.state.isPresented)
    }

    // MARK: - Navigation Path Management

    @Test func testNavigationPathOperations() async {
        let navigator = Navigator(owner: .root)
        let destination = MockDestination.screen1
        
        // Test push
        await navigator.push(destination)
        #expect(navigator.state.path.count == 1)
        
        // Test pop
        let popped = await navigator.pop()
        #expect(popped)
        #expect(navigator.state.path.isEmpty)
    }

    @Test func testMultiplePathOperations() async {
        let navigator = Navigator(owner: .root)
        
        // Push multiple destinations
        await navigator.push(MockDestination.screen1)
        await navigator.push(MockDestination.screen2)
        await navigator.push(MockDestination.screen3)
        #expect(navigator.state.path.count == 3)

        // Pop to root
        let popped = await navigator.popAll()
        #expect(popped)
        #expect(navigator.state.path.isEmpty)
    }

    // MARK: - Sheet Presentation Tests

    @Test func testSheetPresentation() async {
        let navigator = Navigator(owner: .root)
        let destination = MockDestination.screen1

        // Present sheet
        await navigator.navigate(to: destination, method: .sheet)
        #expect(navigator.state.sheet != nil)
        #expect(navigator.state.sheet?.wrapped as? MockDestination == destination)

        // Dismiss sheet
        await navigator.dismissPresentedViews()
        #expect(navigator.state.sheet == nil)
    }

    // MARK: - Navigation Lock Tests

    @Test func testNavigationLocking() async {
        let navigator = Navigator(owner: .root)
        let lockId = UUID()

        // Add lock
        navigator.state.addNavigationLock(id: lockId)
        #expect(navigator.isNavigationLocked)

        // Try to dismiss (should fail)
        await #expect(throws: NavigationState.NavigationError.navigationLocked) {
            try await navigator.dismissAny()
        }

        // Remove lock
        navigator.state.removeNavigationLock(id: lockId)
        #expect(!navigator.isNavigationLocked)
    }

    // MARK: - Child Navigation Tests

    @Test func testChildNavigatorManagement() async {
        let parent = Navigator(owner: .root, name: "parent")
        let child1 = NavigationState(owner: .stack, name: "child1")
        let child2 = NavigationState(owner: .stack, name: "child2")

        // Add children
        parent.state.addChild(child1, isPresented: true)
        parent.state.addChild(child2, isPresented: false)

        #expect(parent.state.children.count == 2)
        #expect(child1.parent?.id == parent.state.id)
        #expect(child2.parent?.id == parent.state.id)

        // Remove child
        parent.state.removeChild(child1)
        #expect(parent.state.children.count == 1)
    }
}
