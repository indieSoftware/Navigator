//
//  NavigatorCoreTests.swift
//  Navigator
//
//  Created by zzmasoud on 02/15/25.
//

import Testing
import Foundation
@testable import NavigatorUI

@MainActor
struct NavigatorCoreTests {

    // MARK: - Basic Navigation State Tests

    @Test func testNavigatorInitialization() {
        let config = NavigationConfiguration(restorationKey: "test")
        let navigator = Navigator(configuration: config)

        #expect(navigator.configuration?.restorationKey == "test")
        #expect(navigator.path.isEmpty)
        #expect(navigator.sheet == nil)
        #expect(navigator.cover == nil)
    }

    @Test func testNavigatorHierarchy() {
        let parentNavigator = Navigator(owner: .root, name: "parent")
        let childNavigator = Navigator(owner: .stack, name: "child")
        parentNavigator.addChild(childNavigator, dismissible: nil)

        #expect(childNavigator.parent?.id == parentNavigator.id)
        #expect(childNavigator.root.id == parentNavigator.id)
    }

    // MARK: - Navigation Lock Tests

    @Test func testNavigationLocking() async throws {
        let navigator = Navigator(owner: .root, name: nil)
        let lockId = UUID()

        // Add lock
        navigator.addNavigationLock(id: lockId)
        #expect(navigator.isNavigationLocked)

        // Try to dismiss (should fail)
        #expect(throws: Navigator.NavigationError.navigationLocked) {
            try navigator.dismissAny()
        }

        // Remove lock
        navigator.removeNavigationLock(id: lockId)
        #expect(!navigator.isNavigationLocked)
    }

    // MARK: - Child Navigation Tests

    @Test func testChildNavigatorManagement() async {
        let parent = Navigator(owner: .root, name: "parent")
        let child1 = Navigator(owner: .stack, name: "child1")
        let child2 = Navigator(owner: .stack, name: "child2")

        // Add children
        parent.addChild(child1, dismissible: nil)
        parent.addChild(child2, dismissible: nil)

        #expect(parent.children.count == 2)
        #expect(child1.parent?.id == parent.id)
        #expect(child2.parent?.id == parent.id)

        // Remove child
        parent.removeChild(child1)
        #expect(parent.children.count == 1)
    }

}
