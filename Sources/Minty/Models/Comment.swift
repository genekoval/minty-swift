import Foundation

public struct Comment: Codable, Hashable, Identifiable {
    public var id: UUID
    public var content: String
    public var indent: Int
    public var dateCreated: Date
}
