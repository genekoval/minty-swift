import Foundation
import Zipline

public struct Post: ZiplineObject {
    public var id: String = ""
    public var title: String?
    public var description: String?
    public var dateCreated: Date = Date()
    public var dateModified: Date = Date()
    public var objects: [ObjectPreview] = []
    public var tags: [TagPreview] = []

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.title),
        Coder(\Self.description),
        Coder(\Self.dateCreated),
        Coder(\Self.dateModified),
        Coder(\Self.objects),
        Coder(\Self.tags)
    ]}

    public init() { }
}
