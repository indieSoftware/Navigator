//
//  NavigationStorage.swift
//  Navigator
//
//  Created by Michael Long on 11/24/24.
//

import SwiftUI

extension Navigator {

    // Experimental
    internal func encoded() -> Data? {
        let path = try? path.codable.map(encoder.encode)
        let storage = NavigationStorage(
            id: id,
            path: path ?? Data(),
            checkpoints: checkpoints,
            dismissible: dismissible
        )
        return try? encoder.encode(storage)
    }

    // Experimental
    internal func restore(from data: Data) {
        do {
            let storage = try decoder.decode(NavigationStorage.self, from: data)
            id = storage.id
            checkpoints = storage.checkpoints
            dismissible = storage.dismissible
            let representation = try decoder.decode(NavigationPath.CodableRepresentation.self, from: storage.path)
            path = NavigationPath(representation)
        } catch {
            path = NavigationPath()
        }
    }

}

internal struct NavigationStorage {
    var id: UUID
    var path: Data
    var checkpoints: [String: NavigationCheckpoint]
    var dismissible: Bool
//    let sheet: AnyNavigationDestination?
//    let fullScreenCover: AnyNavigationDestination?

    internal init(
        id: UUID = UUID(),
        path: Data = Data(),
        checkpoints: [String : NavigationCheckpoint] = [:],
        dismissible: Bool = false
    ) {
        self.id = id
        self.path = path
        self.checkpoints = checkpoints
        self.dismissible = dismissible
    }
}

extension NavigationStorage: Codable {

//    enum CodingKeys: String, CodingKey {
//        case id
//        case path
//        case checkpoints
//        case dismissible
//    }
//
//    internal init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(UUID.self, forKey: .id)
//        path = try container.decode(Data.self, forKey: .path)
//        checkpoints = try container.decode([String: NavigationCheckpoint].self, forKey: .checkpoints)
//        dismissible = try container.decode(Bool.self, forKey: .dismissible)
//    }
//
//    internal func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(path, forKey: .path)
//        try container.encode(checkpoints, forKey: .checkpoints)
//        try container.encode(dismissible, forKey: .dismissible)
//    }

}
