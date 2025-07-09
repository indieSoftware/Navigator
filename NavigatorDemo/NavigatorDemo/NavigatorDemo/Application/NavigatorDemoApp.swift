//
//  NavigatorDemoApp.swift
//  NavigatorDemo
//
//  Created by Michael Long on 11/19/24.
//

import Darwin
import Foundation
import NavigatorUI
import SwiftUI

@main
struct NavigatorDemoApp: App {
    @State var initialized = false
    var body: some Scene {
        WindowGroup {
            if initialized {
                ApplicationRootView()
            } else {
                ProgressView()
                    .task {
                        await initialize()
                    }
            }
        }
    }
    func initialize() async {
        checkMainThread()
        // one might need to split high priority tasks into it's own await if other tasks are dependent on the results
        await withTaskGroup(of: Void.self) { group in
            group.addTask(priority: .high) {
                await A.task1()
            }
            group.addTask(priority: .medium) {
                await A.task2()
            }
            group.addTask(priority: .low) {
                await A.task3()
            }
        }
        checkMainThread()
        initialized = true
    }
}

nonisolated
class A {
    static func task1() async {
        for i in 0..<1_000_000 { _ = i }
        checkMainThread()
    }

    static func task2() async {
        for i in 0..<1_000_000 { _ = i }
        checkMainThread()
    }

    static func task3() async {
        await task4()
        checkMainThread()
    }

    @MainActor static func task4() async {
        for i in 0..<1_000_000 { _ = i }
        checkMainThread()
    }
}

nonisolated func checkMainThread(_ location: String = #function) {
    print(Thread.isMainThread ? "\(location): Main Thread" : "\(location): Thread \(currentThreadID())")
}

nonisolated func currentThreadID() -> UInt64 {
    let pthread = pthread_self()
    let machThreadID = pthread_mach_thread_np(pthread)
    return UInt64(machThreadID)
}
