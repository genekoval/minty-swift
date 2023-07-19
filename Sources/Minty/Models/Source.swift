import Foundation
import Zipline

public struct Source: Codable, Hashable, Identifiable, ZiplineObject {
    public static var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.url),
        Coder(\Self.icon)
    ]}

    public var id: Int64 = -1
    public var url: String = ""
    public var icon: UUID?

    public init() { }
}
