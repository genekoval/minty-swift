import Foundation
import Zipline

public struct PostParts: Codable, Hashable, ZiplineObject {
    public var title: String?
    public var description: String?
    public var objects: [UUID] = []
    public var tags: [UUID] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.title),
        Coder(\Self.description),
        Coder(\Self.objects),
        Coder(\Self.tags),
    ]}

    public init() { }
}
