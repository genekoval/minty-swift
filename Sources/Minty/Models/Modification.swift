import Foundation
import Zipline

public struct Modification<T: ZiplineCodable>: ZiplineCodable {
    public static func decode(
        from decoder: ZiplineDecoder
    ) async throws -> Modification<T> {
        let modified = try await Date.decode(from: decoder)
        let newValue = try await T.decode(from: decoder)

        return Modification(newValue: newValue, modified: modified)
    }

    public var modified: Date
    public var newValue: T

    public init(newValue: T, modified: Date = Date()) {
        self.newValue = newValue
        self.modified = modified
    }

    public func encode(to encoder: ZiplineEncoder) async throws {
        try await modified.encode(to: encoder)
        try await newValue.encode(to: encoder)
    }
}
