import Zipline

public struct TagName: Codable, Hashable, ZiplineObject {
    public static var coders: [Coder<Self>] {[
        Coder(\Self.name),
        Coder(\Self.aliases)
    ]}

    public var name: String = ""
    public var aliases: [String] = []

    public init() { }
}
