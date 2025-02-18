//
//  Logging.swift
//  NavigatorDemo
//
//  Created by Michael Long on 1/30/25.
//

import Foundation

public protocol Logging {
    func log(_ message: String)
}

public struct Logger: Logging {
    public func log(_ message: String) {
        print(message)
    }
}

public struct FeedItem: Codable {
    let title: String
}

enum MyError: Error {
    case connectivity
    case invalidData
    case badStatus(Int)
}

public func load(url: URL) async throws -> [FeedItem] {
    do {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MyError.invalidData
        }
        guard httpResponse.statusCode == 200 else {
            throw MyError.badStatus(httpResponse.statusCode)
        }
        return try JSONDecoder().decode([FeedItem].self, from: data)
    } catch is DecodingError {
        throw MyError.invalidData
    } catch {
        throw MyError.connectivity
    }
}

extension Result {
    func onSuccess(_ handler: (Success) -> Void, failure: (Failure) -> Void) -> Self {
        switch self {
        case .success(let value):
            handler(value)
        case .failure(let error):
            failure(error)
        }
        return self
    }
}
