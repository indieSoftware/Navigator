//
//  NavigationSceneStorage.swift
//  Navigator
//
//  Created by Michael Long on 11/24/24.
//

import SwiftUI

/// Provides state restoration storage for named ManagedNavigationControllers.
internal struct NavigationSceneStorage: Codable {

    let id: UUID
    let name: String?
    let restorationKey: String
    let path: Data?
    let checkpoints: [String: NavigationCheckpoint]
    let dismissible: Bool
    let sheet: Data?
    let cover: Data?

    internal init(
        id: UUID = UUID(),
        name: String?,
        restorationKey: String,
        path: Data?,
        checkpoints: [String : NavigationCheckpoint] = [:],
        dismissible: Bool = false,
        sheet: Data?,
        cover: Data?
    ) {
        self.id = id
        self.name = name
        self.restorationKey = restorationKey
        self.path = path
        self.checkpoints = checkpoints
        self.dismissible = dismissible
        self.sheet = sheet
        self.cover = cover
    }

}

extension NavigationState {

    internal static let decoder = JSONDecoder()
    internal static let encoder = JSONEncoder()

    /// Encoding for scene storage
    internal func encoded() -> Data? {
        guard let restorationKey = configuration?.restorationKey else {
            return nil
        }
        let path = try? path.codable.map(NavigationState.encoder.encode)
        let storage = NavigationSceneStorage(
            id: id,
            name: name,
            restorationKey: restorationKey,
            path: path ?? Data(),
            checkpoints: checkpoints,
            dismissible: isPresented,
            sheet: try? NavigationState.encoder.encode(sheet),
            cover: try? NavigationState.encoder.encode(cover)
        )
        return try? NavigationState.encoder.encode(storage)
    }

    /// Decoding from scene storage
    internal func restore(from data: Data) {
        guard let storage = try? NavigationState.decoder.decode(NavigationSceneStorage.self, from: data),
              storage.restorationKey == configuration?.restorationKey else {
            return
        }
        id = storage.id
        if let data = storage.path, let representation = try? NavigationState.decoder.decode(NavigationPath.CodableRepresentation.self, from: data) {
            path = NavigationPath(representation)
        } else {
            path = .init()
        }
        checkpoints = storage.checkpoints
        isPresented = storage.dismissible
        if let data = storage.sheet {
            sheet = try? NavigationState.decoder.decode(AnyNavigationDestination.self, from: data)
        } else {
            sheet = nil
        }
        if let data = storage.cover {
            cover = try? NavigationState.decoder.decode(AnyNavigationDestination.self, from: data)
        } else {
            cover = nil
        }
    }

}
