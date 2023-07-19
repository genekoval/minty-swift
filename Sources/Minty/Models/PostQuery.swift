import Foundation
import Zipline

public struct PostQuery: ZiplineObject {
    public struct Sort: ZiplineObject {
        public enum SortValue: UInt8, ZiplineCodable {
            public static func decode(
                from decoder: ZiplineDecoder
            ) async throws -> PostQuery.Sort.SortValue {
                let value = try await UInt8.decode(from: decoder)

                guard let result = SortValue(rawValue: value) else {
                    throw MintyError.unspecified(
                        message: "unknown post sort value: \(value)"
                    )
                }

                return result
            }

            case dateCreated
            case dateModified
            case relevance
            case title

            public func encode(to encoder: ZiplineEncoder) async throws {
                try await rawValue.encode(to: encoder)
            }
        }

        public static var coders: [Coder<Self>] {[
            Coder(\Self.order),
            Coder(\Self.value)
        ]}

        public var order: SortOrder = .ascending
        public var value: SortValue = .dateCreated

        public init() { }
    }

    public static var coders: [Coder<Self>] {[
        Coder(\Self.from),
        Coder(\Self.size),
        Coder(\Self.text),
        Coder(\Self.tags),
        Coder(\Self.visibility),
        Coder(\Self.sort)
    ]}

    public var from: UInt32 = 0
    public var size: UInt32 = 0
    public var text: String?
    public var tags: [UUID] = []
    public var visibility: Visibility = .pub
    public var sort: Sort = Sort()

    public init() { }
}
