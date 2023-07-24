import Foundation

public struct Tag: Codable, Hashable, Identifiable {
    public var id: UUID
    public var name: String
    public var aliases: [String]
    public var description: String?
    public var avatar: UUID?
    public var banner: UUID?
    public var sources: [Source]
    public var postCount: Int
    public var dateCreated: Date
}
