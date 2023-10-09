import Foundation

public struct Post: Codable, Hashable, Identifiable {
    public var id: UUID
    public var title: String
    public var description: String
    public var visibility: Visibility
    public var dateCreated: Date
    public var dateModified: Date
    public var objects: [ObjectPreview]
    public var posts: [PostPreview]
    public var tags: [TagPreview]
    public var commentCount: Int
}
