import Foundation
import Zipline

public struct CommentDetail: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: UUID = .empty
    public var postId: UUID = .empty
    public var parentId: UUID?
    public var indent: Int16 = 0
    public var content = ""
    public var dateCreated = Date()

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.postId),
        Coder(\Self.parentId),
        Coder(\Self.indent),
        Coder(\Self.content),
        Coder(\Self.dateCreated)
    ]}

    public init() { }
}
