import Foundation

public struct CommentDetail: Codable, Hashable, Identifiable {
    public var id: UUID
    public var postId: UUID
    public var parentId: UUID?
    public var indent: Int
    public var content: String
    public var dateCreated: Date
}
