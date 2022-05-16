import Foundation
import Zipline

public struct Comment: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: UUID = .empty
    public var content: String = ""
    public var indent: Int16 = 0
    public var dateCreated: Date = Date()

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.content),
        Coder(\Self.indent),
        Coder(\Self.dateCreated)
    ]}

    public init() { }
}
