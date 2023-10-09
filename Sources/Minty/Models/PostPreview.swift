import Foundation

public struct PostPreview: Codable, Hashable, Identifiable {
    public var id: UUID
    public var title: String
    public var preview: ObjectPreview?
    public var commentCount: Int
    public var objectCount: Int
    public var dateCreated: Date
}
