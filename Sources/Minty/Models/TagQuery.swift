import Zipline

public struct TagQuery: ZiplineObject {
    public var from: UInt32 = 0
    public var size: UInt32 = 0
    public var name: String = ""
    public var exclude: [String] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.from),
        Coder(\Self.size),
        Coder(\Self.name),
        Coder(\Self.exclude)
    ]}

    public init() { }
}
