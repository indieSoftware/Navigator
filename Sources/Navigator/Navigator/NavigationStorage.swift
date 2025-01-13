//
//  NavigationStorage.swift
//  Navigator
//
//  Created by Michael Long on 11/24/24.
//

import SwiftUI

/// Provides state restoration storage for named ManagedNavigationControllers.
internal struct NavigationStorage: Codable {

    let id: UUID
    let restorationKey: String
    let path: Data?
    let checkpoints: [String: NavigationCheckpoint]
    let dismissible: Bool
    let sheet: Data?
    let cover: Data?

    internal init(
        id: UUID = UUID(),
        restorationKey: String,
        path: Data?,
        checkpoints: [String : NavigationCheckpoint] = [:],
        dismissible: Bool = false,
        sheet: Data?,
        cover: Data?
    ) {
        self.id = id
        self.restorationKey = restorationKey
        self.path = path
        self.checkpoints = checkpoints
        self.dismissible = dismissible
        self.sheet = sheet
        self.cover = cover
    }

}

extension Navigator {

    /// Encoding for scene storage
    internal func encoded() -> Data? {
        guard let restorationKey = configuration?.restorationKey else {
            return nil
        }
        let path = try? path.codable.map(encoder.encode)
        let storage = NavigationStorage(
            id: id,
            restorationKey: restorationKey,
            path: path ?? Data(),
            checkpoints: checkpoints,
            dismissible: isPresented,
            sheet: try? encoder.encode(sheet),
            cover: try? encoder.encode(cover)
        )
        return try? encoder.encode(storage)
    }

    /// Decoding from scene storage
    internal func restore(from data: Data) {
        guard let storage = try? decoder.decode(NavigationStorage.self, from: data),
              storage.restorationKey == configuration?.restorationKey else {
            return
        }
        id = storage.id
        if let data = storage.path, let representation = try? decoder.decode(NavigationPath.CodableRepresentation.self, from: data) {
            path = NavigationPath(representation)
        } else {
            path = .init()
        }
        checkpoints = storage.checkpoints
        isPresented = storage.dismissible
        if let data = storage.sheet {
            sheet = try? decoder.decode(AnyNavigationDestination.self, from: data)
        } else {
            sheet = nil
        }
        if let data = storage.cover {
            cover = try? decoder.decode(AnyNavigationDestination.self, from: data)
        } else {
            cover = nil
        }
    }

}

extension AnyNavigationDestination: Codable {

    // Adapted from https://www.pointfree.co/blog/posts/78-reverse-engineering-swiftui-s-navigationpath-codability

    // convert data to NavigationDestination
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let typeName = try container.decode(String.self)
        let type = _typeByName(typeName)
        guard let type = type as? any Decodable.Type else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(typeName) is not decodable.")
        }
        guard let destination = (try container.decode(type)) as? any NavigationDestination else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(typeName) is not decodable.")
        }
        wrapped = destination
    }

    // convert NavigationDestination to storable data
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(_mangledTypeName(type(of: wrapped)))
        guard let element = wrapped as? any Encodable else {
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "\(type(of: wrapped)) is not encodable.")
            throw EncodingError.invalidValue(wrapped, context)
        }
        try container.encode(element)
    }

}
