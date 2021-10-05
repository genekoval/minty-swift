import Zipline

public struct DataSize: ZiplineObject {
    public var bytes: UInt64 = 0
    public var formatted: String = ""

    public var coders: [Coder<Self>] {[
        Coder(\Self.bytes),
        Coder(\Self.formatted)
    ]}

    public init() { }
}
