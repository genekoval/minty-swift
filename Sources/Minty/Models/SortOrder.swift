import Zipline

public enum SortOrder: UInt8, ZiplineCodable {
    public static func decode(
        from decoder: ZiplineDecoder
    ) async throws -> SortOrder {
        let value = try await UInt8.decode(from: decoder)

        guard let result = SortOrder(rawValue: value) else {
            throw MintyError.unspecified(
                message: "unknown sort order: \(value)"
            )
        }

        return result
    }

    case ascending
    case descending

    public func encode(to encoder: ZiplineEncoder) async throws {
        try await rawValue.encode(to: encoder)
    }
}
