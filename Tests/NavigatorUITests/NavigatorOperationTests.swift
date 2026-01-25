//
//  NavigatorOperationTests.swift
//  Navigator
//
//  Created by hmlong on 02/20/25.
//

import Testing
import Foundation
@testable import NavigatorUI

@MainActor
struct NavigatorOperationTests {

    // MARK: - Navigation Path Management

    @Test func testNavigationPathOperations() async {
        let navigator = Navigator(owner: .root, name: nil)
        let destination = MockDestination.screen1

        // Test push
        navigator.push(destination)
        #expect(navigator.path.count == 1)

        // Test pop
        let popped = navigator.pop()
        #expect(popped)
        #expect(navigator.path.isEmpty)
    }

    @Test func testMultiplePathOperations() async {
        let navigator = Navigator(owner: .root, name: nil)

        // Push multiple destinations
        navigator.push(MockDestination.screen1)
        navigator.push(MockDestination.screen2)
        navigator.push(MockDestination.screen3)
        #expect(navigator.path.count == 3)

        // Pop to root
        let popped = navigator.popAll()
        #expect(popped)
        #expect(navigator.path.isEmpty)
    }

    // MARK: - Sheet Presentation Tests

    @Test func testSheetPresentation() async {
        let navigator = Navigator(owner: .root, name: nil)
        let destination = MockDestination.screen1

        // Present sheet
        navigator.navigate(to: destination, method: .sheet)
        #expect(navigator.sheet != nil)
        #expect(navigator.sheet?.wrapped as? MockDestination == destination)

        // Dismiss sheet
        navigator.dismissPresentedViews()
        #expect(navigator.sheet == nil)
    }

}
