import Zipline

extension Range: ZiplineCodable where Bound: ZiplineCodable {
    public static func decode(
        from decoder: ZiplineDecoder
    ) async throws -> Range<Bound> {
        let lower = try await Bound.decode(from: decoder)
        let upper = try await Bound.decode(from: decoder)

        return lower..<upper
    }

    public func encode(to encoder: ZiplineEncoder) async throws {
        try await self.lowerBound.encode(to: encoder)
        try await self.upperBound.encode(to: encoder)
    }
}
