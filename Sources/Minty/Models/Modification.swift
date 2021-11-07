import Foundation
import Zipline

public struct Modification<T: ZiplineCodable>: ZiplineCodable {
    public var modified: Date
    public var newValue: T

    public init(from decoder: ZiplineDecoder) throws {
        modified = try Date(from: decoder)
        newValue = try T(from: decoder)
    }

    public func encode(to encoder: ZiplineEncoder) {
        modified.encode(to: encoder)
        newValue.encode(to: encoder)
    }
}
