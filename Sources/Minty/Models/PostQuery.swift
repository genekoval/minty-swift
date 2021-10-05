import Zipline

public struct PostQuery: ZiplineObject {
    public struct Sort: ZiplineObject {
        public enum SortValue: UInt8, ZiplineCodable {
            case dateCreated
            case dateModified
            case relevance
            case title

            public init(from decoder: ZiplineDecoder) throws {
                self.init(rawValue: try UInt8(from: decoder))!
            }

            public func encode(to encoder: ZiplineEncoder) {
                rawValue.encode(to: encoder)
            }
        }

        public var order: SortOrder = .ascending
        public var value: SortValue = .dateCreated

        public var coders: [Coder<Self>] {[
            Coder(\Self.order),
            Coder(\Self.value)
        ]}

        public init() { }
    }

    public var from: Int8 = 0
    public var size: Int8 = 0
    public var text: String?
    public var tags: [String] = []
    public var sort: Sort = Sort()

    public var coders: [Coder<Self>] {[
        Coder(\Self.from),
        Coder(\Self.size),
        Coder(\Self.text),
        Coder(\Self.tags),
        Coder(\Self.sort)
    ]}

    public init() { }
}
