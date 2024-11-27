//
//  NavigationStorage.swift
//  Navigator
//
//  Created by Michael Long on 11/24/24.
//

import SwiftUI

internal struct NavigationStorage: Codable {

    var id: UUID
    var path: Data?
    var checkpoints: [String: NavigationCheckpoint]
    var dismissible: Bool
    let sheet: Data?
    let fullScreenCover: Data?

    internal init(
        id: UUID = UUID(),
        path: Data?,
        checkpoints: [String : NavigationCheckpoint] = [:],
        dismissible: Bool = false,
        sheet: Data?,
        fullScreenCover: Data?
    ) {
        self.id = id
        self.path = path
        self.checkpoints = checkpoints
        self.dismissible = dismissible
        self.sheet = sheet
        self.fullScreenCover = fullScreenCover
    }

}

extension Navigator {

    /// Encoding for scene storage
    internal func encoded() -> Data? {
        let path = try? path.codable.map(encoder.encode)
        let storage = NavigationStorage(
            id: id,
            path: path ?? Data(),
            checkpoints: checkpoints,
            dismissible: dismissible,
            sheet: try? encoder.encode(sheet),
            fullScreenCover: try? encoder.encode(fullScreenCover)
        )
        return try? encoder.encode(storage)
    }

    /// Decoding from scene storage
    internal func restore(from data: Data) {
        guard let storage = try? decoder.decode(NavigationStorage.self, from: data) else {
            return
        }
        id = storage.id
        if let data = storage.path, let representation = try? decoder.decode(NavigationPath.CodableRepresentation.self, from: data) {
            path = NavigationPath(representation)
        } else {
            path = .init()
        }
        checkpoints = storage.checkpoints
        dismissible = storage.dismissible
        if let data = storage.sheet {
            sheet = try? decoder.decode(AnyNavigationDestination.self, from: data)
        } else {
            sheet = nil
        }
        if let data = storage.fullScreenCover {
            fullScreenCover = try? decoder.decode(AnyNavigationDestination.self, from: data)
        } else {
            fullScreenCover = nil
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
