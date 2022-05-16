import Foundation
import Zipline

public struct Source: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: String = ""
    public var url: String = ""
    public var icon: UUID?

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.url),
        Coder(\Self.icon)
    ]}

    public init() { }
}
