import Foundation
import Zipline

public struct Object: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: UUID = .empty
    public var hash: String = ""
    public var size: DataSize = DataSize()
    public var type: String = ""
    public var subtype: String = ""
    public var dateAdded: Date = Date()
    public var previewId: UUID?
    public var source: Source?
    public var posts: [PostPreview] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.hash),
        Coder(\Self.size),
        Coder(\Self.type),
        Coder(\Self.subtype),
        Coder(\Self.dateAdded),
        Coder(\Self.previewId),
        Coder(\Self.source),
        Coder(\Self.posts)
    ]}

    public init() { }
}
