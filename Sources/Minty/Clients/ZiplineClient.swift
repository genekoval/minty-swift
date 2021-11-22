import Foundation
import Fstore
import Zipline

private typealias Client = Zipline.ZiplineClient<MintyEvent, MintyError>

private let bufferSize = 8192

private func connect(host: String, port: UInt16) -> Client {
    Zipline.ZiplineClient(coder: ZiplineConnection(
        host: host,
        port: port,
        bufferSize: bufferSize
    ))
}

public final class ZiplineClient: MintyRepo {
    public let host: String
    private let info: ServerInfo
    private let objectStore: ObjectStore
    public let port: UInt16

    public var serverVersion: String { info.version }

    public init(host: String, port: UInt16) throws {
        self.host = host
        self.port = port

        info = try Minty.connect(host: host, port: port)
            .request(event: .getServerInfo)

        objectStore = Fstore.ZiplineClient(
            host: info.objectSource.host ?? host,
            port: info.objectSource.port
        )
    }

    private func connect() -> Client {
        Minty.connect(host: host, port: port)
    }

    public func addComment(
        postId: String,
        parentId: String?,
        content: String
    ) throws -> Comment {
        try connect().request(event: .addComment, postId, parentId, content)
    }

    public func addObjectData(
        count: Int,
        data: @escaping (DataWriter) -> Void
    ) throws -> String {
        try connect().request(
            event: .addObjectData,
            ObjectPart(count: count, src: data)
        )
    }

    public func addObjectsUrl(url: String) throws -> [String] {
        try connect().request(event: .addObjectsUrl, url)
    }

    public func addPost(parts: PostParts) throws -> String {
        try connect().request(event: .addPost, parts)
    }

    public func addPostObjects(
        postId: String,
        objects: [String],
        position: UInt32
    ) throws -> [ObjectPreview] {
        try connect().request(event: .addPostObjects, postId, objects, position)
    }

    public func addPostTag(postId: String, tagId: String) throws {
        try connect().send(event: .addPostTag, postId, tagId)
    }

    public func addTag(name: String) throws -> String {
        try connect().request(event: .addTag, name)
    }

    public func addTagAlias(tagId: String, alias: String) throws -> TagName {
        try connect().request(event: .addTagAlias, tagId, alias)
    }

    public func addTagSource(tagId: String, url: String) throws -> Source {
        try connect().request(event: .addTagSource, tagId, url)
    }

    public func deletePost(postId: String) throws {
        try connect().send(event: .deletePost, postId)
    }

    public func deletePostObjects(postId: String, objects: [String]) throws {
        try connect().send(event: .deletePostObjects, postId, objects)
    }

    public func deletePostObjects(
        postId: String,
        ranges: [Range<Int32>]
    ) throws {
        try connect().send(event: .deletePostObjectsRanges, postId, ranges)
    }

    public func deletePostTag(postId: String, tagId: String) throws {
        try connect().send(event: .deletePostTag, postId, tagId)
    }

    public func deleteTag(tagId: String) throws {
        try connect().send(event: .deleteTag, tagId)
    }

    public func deleteTagAlias(tagId: String, alias: String) throws -> TagName {
        try connect().request(event: .deleteTagAlias, tagId, alias)
    }

    public func deleteTagSource(tagId: String, sourceId: String) throws {
        try connect().send(event: .deleteTagSource, tagId, sourceId)
    }

    public func getComments(postId: String) throws -> [Comment] {
        try connect().request(event: .getComments, postId)
    }

    public func getObject(objectId: String) throws -> Object {
        try connect().request(event: .getObject, objectId)
    }

    public func getObjectData(
        objectId: String,
        handler: (Data) -> Void
    ) throws {
        try objectStore.getObject(
            bucketId: info.objectSource.bucketId,
            objectId: objectId,
            handler: handler
        )
    }

    public func getPost(postId: String) throws -> Post {
        try connect().request(event: .getPost, postId)
    }

    public func getPosts(query: PostQuery) throws -> SearchResult<PostPreview> {
        try connect().request(event: .getPosts, query)
    }

    public func getServerInfo() throws -> ServerInfo {
        return info
    }

    public func getTag(tagId: String) throws -> Tag {
        try connect().request(event: .getTag, tagId)
    }

    public func getTags(query: TagQuery) throws -> SearchResult<TagPreview> {
        try connect().request(event: .getTags, query)
    }

    public func movePostObject(
        postId: String,
        oldIndex: UInt32,
        newIndex: UInt32
    ) throws {
        try connect().send(event: .movePostObject, postId, oldIndex, newIndex)
    }

    public func setCommentContent(
        commentId: String,
        content: String
    ) throws -> String {
        try connect().request(event: .setCommentContent, commentId, content)
    }

    public func setPostDescription(
        postId: String,
        description: String
    ) throws -> Modification<String?> {
        try connect().request(event: .setPostDescription, postId, description)
    }

    public func setPostTitle(
        postId: String,
        title: String
    ) throws -> Modification<String?> {
        try connect().request(event: .setPostTitle, postId, title)
    }

    public func setTagDescription(
        tagId: String,
        description: String
    ) throws -> String? {
        try connect().request(event: .setTagDescription, tagId, description)
    }

    public func setTagName(tagId: String, newName: String) throws -> TagName {
        try connect().request(event: .setTagName, tagId, newName)
    }
}
