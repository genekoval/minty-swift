import Foundation

public struct Source: Codable, Hashable, Identifiable {
    public var id: Int64
    public var url: String
    public var icon: UUID?
}
