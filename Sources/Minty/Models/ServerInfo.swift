import Foundation

public struct ObjectSource: Codable, Hashable {
    public var host: String?
    public var port: Int
    public var bucketId: UUID
}

public struct ServerInfo: Codable, Hashable {
    public var version: String
    public var objectSource: ObjectSource
}
