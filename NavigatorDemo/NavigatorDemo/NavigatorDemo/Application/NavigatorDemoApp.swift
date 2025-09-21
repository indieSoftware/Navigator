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
    @State var state: InitializationState = .required
    var body: some Scene {
        WindowGroup {
            if state == .initialized {
                ApplicationRootView()
            } else {
                ProgressView()
                    .task {
                        await initialize()
                    }
            }
        }
    }
}

extension NavigatorDemoApp{

    func initialize() async {
        guard state == .required else {
            return
        }
        state = .initializing
        await withTaskGroup(of: Void.self) { group in
            for task in Self.tasks {
                group.addTask(priority: task.priority, operation: task.operation)
            }
        }
        state = .initialized
    }

    enum InitializationState {
        case required
        case initializing
        case initialized
    }

    nonisolated struct InitializationTask {
        let priority: TaskPriority
        let operation: @isolated(any) @Sendable () async -> Void
    }

    nonisolated static let tasks: [InitializationTask] = [
        .init(priority: .high, operation: { await task1() }),
        .init(priority: .high, operation: { await task2() }),
        .init(priority: .low, operation: { await task3() }),
        .init(priority: .medium, operation: { await task4() }),
    ]

}

private nonisolated let iterations = 100_000

nonisolated func task1() async {
    for i in 0..<iterations { _ = i }
    checkMainThread()
}

nonisolated func task2() async {
    for i in 0..<iterations { _ = i }
    checkMainThread()
}

nonisolated func task3() async {
    for i in 0..<iterations { _ = i }
    checkMainThread()
}

nonisolated func task4() async {
    await subtask()
    checkMainThread()
}

@MainActor func subtask() async {
    for i in 0..<iterations { _ = i }
    checkMainThread()
}

nonisolated func checkMainThread(_ location: String = #function) {
    print(Thread.isMainThread ? "\(location): Main Thread" : "\(location): Thread \(currentThreadID())")
}

nonisolated func currentThreadID() -> UInt64 {
    let pthread = pthread_self()
    let machThreadID = pthread_mach_thread_np(pthread)
    return UInt64(machThreadID)
}
