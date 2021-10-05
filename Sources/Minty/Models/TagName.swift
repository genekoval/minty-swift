import Zipline

public struct TagName: ZiplineObject {
    public var name: String = ""
    public var aliases: [String] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.name),
        Coder(\Self.aliases)
    ]}

    public init() { }
}
