import Foundation
import Zipline

public struct Tag: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: UUID = .empty
    public var name: String = ""
    public var aliases: [String] = []
    public var description: String?
    public var avatar: UUID?
    public var banner: UUID?
    public var sources: [Source] = []
    public var postCount: UInt32 = 0
    public var dateCreated: Date = Date()

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.name),
        Coder(\Self.aliases),
        Coder(\Self.description),
        Coder(\Self.avatar),
        Coder(\Self.banner),
        Coder(\Self.sources),
        Coder(\Self.postCount),
        Coder(\Self.dateCreated)
    ]}

    public init() { }
}
