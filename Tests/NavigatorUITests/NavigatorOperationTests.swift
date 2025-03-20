//
//  NavigatorOperationTests.swift
//  Navigator
//
//  Created by hmlong on 02/20/25.
//

import Testing
import Foundation
@testable import NavigatorUI

struct NavigatorOperationTests {

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

}
