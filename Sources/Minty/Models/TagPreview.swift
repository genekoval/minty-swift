import Foundation
import Zipline

public struct TagPreview: Codable, Hashable, Identifiable, ZiplineObject {
    public static var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.name),
        Coder(\Self.avatar)
    ]}

    public var id: UUID = .empty
    public var name: String = ""
    public var avatar: UUID?

    public init() { }
}
