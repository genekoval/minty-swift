import Zipline

public struct TagPreview: ZiplineObject {
    public var id: String = ""
    public var name: String = ""
    public var avatar: String?

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.name),
        Coder(\Self.avatar)
    ]}

    public init() { }
}
