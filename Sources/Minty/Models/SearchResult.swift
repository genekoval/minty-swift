import Zipline

public struct SearchResult<T: ZiplineCodable>: ZiplineObject {
    public var total: UInt32 = 0
    public var hits: [T] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.total),
        Coder(\Self.hits)
    ]}

    public init() { }
}
