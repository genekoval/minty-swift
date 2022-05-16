import Foundation
import Zipline

public struct TagQuery: Codable, Hashable, ZiplineObject {
    public var from: UInt32 = 0
    public var size: UInt32 = 0
    public var name: String = ""
    public var exclude: [UUID] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.from),
        Coder(\Self.size),
        Coder(\Self.name),
        Coder(\Self.exclude)
    ]}

    public init() { }
}
