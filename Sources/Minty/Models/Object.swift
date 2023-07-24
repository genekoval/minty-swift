import Foundation

public struct Object: Codable, Hashable, Identifiable {
    public var id: UUID
    public var hash: String
    public var size: DataSize
    public var type: String
    public var subtype: String
    public var dateAdded: Date
    public var previewId: UUID?
    public var source: Source?
    public var posts: [PostPreview]

    public var preview: ObjectPreview {
        ObjectPreview(
            id: id,
            previewId: previewId,
            type: type,
            subtype: subtype
        )
    }
}
