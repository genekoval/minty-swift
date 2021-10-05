import Foundation
import Zipline

public struct Comment: ZiplineObject, Equatable {
    public var id: String = ""
    public var content: String = ""
    public var indent: UInt32 = 0
    public var dateCreated: Date = Date()

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.content),
        Coder(\Self.indent),
        Coder(\Self.dateCreated)
    ]}

    public init() { }
}
