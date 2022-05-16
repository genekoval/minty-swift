import Foundation
import Zipline

public struct PostPreview: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: UUID = .empty
    public var title: String?
    public var preview: ObjectPreview?
    public var commentCount: UInt32 = 0
    public var objectCount: UInt32 = 0
    public var dateCreated: Date = Date()

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.title),
        Coder(\Self.preview),
        Coder(\Self.commentCount),
        Coder(\Self.objectCount),
        Coder(\Self.dateCreated)
    ]}

    public init() { }
}
