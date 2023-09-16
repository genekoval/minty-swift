import Foundation

public struct ObjectSource: Codable, Hashable {
    public var location: URL
    public var bucket: UUID
}

public struct ServerInfo: Codable, Hashable {
    public var version: String
    public var objectSource: ObjectSource
}
