import Foundation
import Zipline

public struct ObjectSource: Codable, Hashable, ZiplineObject {
    public var bucketId: UUID = .empty
    public var host: String?
    public var port: UInt16 = 0

    public var coders: [Coder<Self>] {[
        Coder(\Self.host),
        Coder(\Self.port),
        Coder(\Self.bucketId)
    ]}

    public init() { }
}

public struct ServerInfo: Codable, Hashable, ZiplineObject {
    public var objectSource: ObjectSource = ObjectSource()
    public var version: String = ""

    public var coders: [Coder<Self>] {[
        Coder(\Self.version),
        Coder(\Self.objectSource)
    ]}

    public init() { }
}
