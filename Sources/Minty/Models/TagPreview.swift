import Foundation

public struct TagPreview: Codable, Hashable, Identifiable {
    public var id: UUID
    public var name: String
    public var avatar: UUID?
}
