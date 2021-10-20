import Foundation
import Zipline

public struct Object: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: String = ""
    public var hash: String = ""
    public var size: DataSize = DataSize()
    public var mimeType: String = ""
    public var dateAdded: Date = Date()
    public var previewId: String?
    public var source: Source?
    public var posts: [PostPreview] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.hash),
        Coder(\Self.size),
        Coder(\Self.mimeType),
        Coder(\Self.dateAdded),
        Coder(\Self.previewId),
        Coder(\Self.source),
        Coder(\Self.posts)
    ]}

    public init() { }
}