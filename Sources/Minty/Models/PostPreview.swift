import Foundation
import Zipline

public struct PostPreview: ZiplineObject {
    public var id: String = ""
    public var title: String?
    public var previewId: String?
    public var commentCount: UInt32 = 0
    public var objectCount: UInt32 = 0
    public var dateCreated: Date = Date()

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.title),
        Coder(\Self.previewId),
        Coder(\Self.commentCount),
        Coder(\Self.objectCount),
        Coder(\Self.dateCreated)
    ]}

    public init() { }
}
