//
//  KnownCheckpoints.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/19/25.
//

import NavigatorUI

struct KnownCheckpoints: NavigationCheckpoints {
    public static var home: NavigationCheckpoint<Void> { checkpoint() }
    public static var page2: NavigationCheckpoint<Void> { checkpoint() }
    public static var duplicate: NavigationCheckpoint<Void> { checkpoint() }
    public static var settings: NavigationCheckpoint<Int> { checkpoint() }
    public static var unknown: NavigationCheckpoint<Void> { checkpoint() }
}
