import Foundation
import Zipline

public struct ObjectSource: Codable, Hashable, ZiplineObject {
    public static var coders: [Coder<Self>] {[
        Coder(\Self.host),
        Coder(\Self.port),
        Coder(\Self.bucketId)
    ]}

    public var bucketId: UUID = .empty
    public var host: String?
    public var port: UInt16 = 0

    public init() { }
}

public struct ServerMetadata: Codable, Hashable, ZiplineObject {
    public static var coders: [Coder<Self>] {[
        Coder(\Self.version)
    ]}

    public var version = ""

    public init() { }
}

public struct ServerInfo: Codable, Hashable, ZiplineObject {
    public static var coders: [Coder<Self>] {[
        Coder(\Self.metadata),
        Coder(\Self.objectSource)
    ]}

    public var metadata = ServerMetadata()
    public var objectSource = ObjectSource()

    public init() { }
}
