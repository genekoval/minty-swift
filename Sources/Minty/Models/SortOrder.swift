import Zipline

public enum SortOrder: UInt8, ZiplineCodable {
    case ascending
    case descending

    public init(from decoder: ZiplineDecoder) throws {
        self.init(rawValue: try UInt8(from: decoder))!
    }

    public func encode(to encoder: ZiplineEncoder) {
        rawValue.encode(to: encoder)
    }
}
