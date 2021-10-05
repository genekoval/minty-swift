import Zipline

extension Range: ZiplineCodable where Bound: ZiplineCodable {
    public init(from decoder: ZiplineDecoder) throws {
        let lower = try Bound(from: decoder)
        let upper = try Bound(from: decoder)

        self = lower..<upper
    }

    public func encode(to encoder: ZiplineEncoder) {
        self.lowerBound.encode(to: encoder)
        self.upperBound.encode(to: encoder)
    }
}
