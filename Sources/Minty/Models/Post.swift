import Foundation
import Zipline

public struct Post: Codable, Hashable, Identifiable, ZiplineObject {
    public static var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.title),
        Coder(\Self.description),
        Coder(\Self.visibility),
        Coder(\Self.dateCreated),
        Coder(\Self.dateModified),
        Coder(\Self.objects),
        Coder(\Self.posts),
        Coder(\Self.tags)
    ]}

    public var id: UUID = .empty
    public var title: String?
    public var description: String?
    public var visibility: Visibility = .invalid
    public var dateCreated: Date = Date()
    public var dateModified: Date = Date()
    public var objects: [ObjectPreview] = []
    public var posts: [PostPreview] = []
    public var tags: [TagPreview] = []

    public init() { }
}
