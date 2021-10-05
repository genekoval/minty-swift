import Zipline

public struct Source: ZiplineObject {
    public var id: String = ""
    public var url: String = ""
    public var icon: String?

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.url),
        Coder(\Self.icon)
    ]}

    public init() { }
}
