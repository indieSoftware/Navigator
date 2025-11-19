//
//  FlowExampleView.swift
//  Navigator
//
//  Created by Michael Long on 2/12/25.
//

import NavigatorUI
import SwiftUI

struct FlowExampleView: View {
    var body: some View {
        ManagedNavigationStack { navigator in
            List {
                Section("Navigation Flows") {
                    Button("Start ABC Flow") {
                        navigator.start(ABCFlow(initialValue: 22))
                    }
                }
                Section {
                    Button("Dismiss Example") {
                        navigator.dismiss()
                    }
                }
            }
            .navigationTitle("Flow Example")
        }
    }
}

nonisolated struct ABCFlow: NavigationFlow {
    var checkpoint: NavigationFlowCheckpoint?

    let initialValue: Int
    var aaaValue: Int?
    var bbbValue: Int?
    var cccValue: Int?

    func start() -> FlowResult<Destinations> {
        .destination(.aaa(self))
    }

    mutating func next() -> FlowResult<Destinations> {
        if bbbValue == nil {
            return .destination(.bbb(self))
        }
        if cccValue == nil {
            return .destination(.ccc(self))
        }
        return .complete
    }
}

extension ABCFlow {
    nonisolated enum Destinations: NavigationDestination {
        case aaa(ABCFlow)
        case bbb(ABCFlow)
        case ccc(ABCFlow)

        var body: some View {
            switch self {
            case let .aaa(flow):
                AAAView(flow)
            case let .bbb(flow):
                BBBView(flow)
            case let .ccc(flow):
                CCCView(flow)
            }
        }

        var method: NavigationMethod {
            switch self {
            case .aaa:
                .managedSheet
            default:
                .push
            }
        }
    }
}

struct AAAView: View {
    @Environment(\.navigator) private var navigator
    @State var flow: ABCFlow
    init(_ flow: ABCFlow) {
        self.flow = flow
    }
    var body: some View {
        List {
            Button("Next from \(flow.initialValue)") {
                flow.aaaValue = 42
                navigator.next(flow)
            }
        }
        .navigationTitle("AAA View")
    }
}

struct BBBView: View {
    @Environment(\.navigator) private var navigator
    @State var flow: ABCFlow
    init(_ flow: ABCFlow) {
        self.flow = flow
    }
    var body: some View {
        List {
            Button("Next") {
                flow.bbbValue = 324
                navigator.next(flow)
            }
        }
        .navigationTitle("BBB View")
    }
}

struct CCCView: View {
    @Environment(\.navigator) private var navigator
    @State var flow: ABCFlow
    init(_ flow: ABCFlow) {
        self.flow = flow
    }
    var body: some View {
        List {
            Button("Done") {
                flow.cccValue = 12
                navigator.next(flow)
            }
        }
        .navigationTitle("CCC View")
    }
}
