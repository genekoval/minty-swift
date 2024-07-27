import Foundation
import SwiftHTTP

public enum MintyError: Swift.Error {
    case serverError
    case networkError(cause: Swift.Error)
    case invalidData(message: String)
    case notFound(entity: String, id: UUID)
    case unauthenticated(message: String?)
    case alreadyExists(message: String)
    case other(message: String)

    static func parseNotFound(message: String) -> Self {
        let search = /(?<entity>.+?) with ID '(?<id>.+?)' not found/
        guard let result = try? search.wholeMatch(in: message) else {
            return .other(message: message)
        }

        guard let id = UUID(uuidString: String(result.id)) else {
            return .other(message: message)
        }

        return .notFound(entity: String(result.entity), id: id)
    }
}
