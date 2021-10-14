import Zipline

public struct ObjectPreview: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: String = ""
    public var previewId: String?
    public var mimeType: String = ""

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.previewId),
        Coder(\Self.mimeType)
    ]}

    public init() { }
}
