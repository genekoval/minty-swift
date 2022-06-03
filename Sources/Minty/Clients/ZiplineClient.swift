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
    public static func create(
        host: String,
        port: UInt16
    ) async throws -> (ZiplineClient, ServerMetadata) {
        let connection = Minty.connect(host: host, port: port)
        let info: ServerInfo = try await connection
            .request(event: .getServerInfo)
        let store = Fstore.ZiplineClient(
            host: info.objectSource.host ?? host,
            port: info.objectSource.port
        )

        let client = ZiplineClient(
            host: host,
            port: port,
            bucketId: info.objectSource.bucketId,
            objectStore: store
        )

        return (client, info.metadata)
    }

    public let host: String
    public let port: UInt16

    private let bucketId: UUID
    private let objectStore: ObjectStore

    private init(
        host: String,
        port: UInt16,
        bucketId: UUID,
        objectStore: ObjectStore
    ) {
        self.host = host
        self.port = port
        self.bucketId = bucketId
        self.objectStore = objectStore
    }

    private func connect() -> Client {
        Minty.connect(host: host, port: port)
    }

    public func addComment(
        postId: UUID,
        content: String
    ) async throws -> Comment {
        try await connect().request(event: .addComment, postId, content)
    }

    public func addObjectData(
        size: Int,
        writer: @escaping (DataWriter) async throws -> Void
    ) async throws -> ObjectPreview {
        let upload = ObjectUpload(size: size, writer: writer)
        return try await connect().request(event: .addObjectData, upload)
    }

    public func addObjectsUrl(url: String) async throws -> [ObjectPreview] {
        try await connect().request(event: .addObjectsUrl, url)
    }

    public func addPost(parts: PostParts) async throws -> UUID {
        try await connect().request(event: .addPost, parts)
    }

    public func addPostObjects(
        postId: UUID,
        objects: [UUID],
        position: Int16
    ) async throws -> Date {
        try await connect()
            .request(event: .addPostObjects, postId, objects, position)
    }

    public func addPostTag(postId: UUID, tagId: UUID) async throws {
        try await connect().send(event: .addPostTag, postId, tagId)
    }

    public func addRelatedPost(postId: UUID, related: UUID) async throws {
        try await connect().send(event: .addRelatedPost, postId, related)
    }

    public func addReply(
        parentId: UUID,
        content: String
    ) async throws -> Comment {
        try await connect().request(event: .addReply, parentId, content)
    }

    public func addTag(name: String) async throws -> UUID {
        try await connect().request(event: .addTag, name)
    }

    public func addTagAlias(
        tagId: UUID,
        alias: String
    ) async throws -> TagName {
        try await connect().request(event: .addTagAlias, tagId, alias)
    }

    public func addTagSource(tagId: UUID, url: String) async throws -> Source {
        try await connect().request(event: .addTagSource, tagId, url)
    }

    public func deletePost(postId: UUID) async throws {
        try await connect().send(event: .deletePost, postId)
    }

    public func deletePostObjects(
        postId: UUID,
        objects: [UUID]
    ) async throws -> Date {
        try await connect().request(event: .deletePostObjects, postId, objects)
    }

    public func deletePostObjects(
        postId: UUID,
        ranges: [Range<Int32>]
    ) async throws -> Date {
        try await connect()
            .request(event: .deletePostObjectsRanges, postId, ranges)
    }

    public func deletePostTag(postId: UUID, tagId: UUID) async throws {
        try await connect().send(event: .deletePostTag, postId, tagId)
    }

    public func deleteRelatedPost(postId: UUID, related: UUID) async throws {
        try await connect().send(event: .deleteRelatedPost, postId, related)
    }

    public func deleteTag(tagId: UUID) async throws {
        try await connect().send(event: .deleteTag, tagId)
    }

    public func deleteTagAlias(
        tagId: UUID,
        alias: String
    ) async throws -> TagName {
        try await connect().request(event: .deleteTagAlias, tagId, alias)
    }

    public func deleteTagSource(tagId: UUID, sourceId: String) async throws {
        try await connect().send(event: .deleteTagSource, tagId, sourceId)
    }

    public func getComment(commentId: UUID) async throws -> CommentDetail {
        try await connect().request(event: .getComment, commentId)
    }

    public func getComments(postId: UUID) async throws -> [Comment] {
        try await connect().request(event: .getComments, postId)
    }

    public func getObject(objectId: UUID) async throws -> Object {
        try await connect().request(event: .getObject, objectId)
    }

    public func getObjectData(
        objectId: UUID,
        handler: (Data) async throws -> Void
    ) async throws {
        try await objectStore.getObject(
            bucketId: bucketId,
            objectId: objectId,
            handler: handler
        )
    }

    public func getPost(postId: UUID) async throws -> Post {
        try await connect().request(event: .getPost, postId)
    }

    public func getPosts(
        query: PostQuery
    ) async throws -> SearchResult<PostPreview> {
        try await connect().request(event: .getPosts, query)
    }

    public func getServerInfo() async throws -> ServerInfo {
        try await connect().request(event: .getServerInfo)
    }

    public func getTag(tagId: UUID) async throws -> Tag {
        try await connect().request(event: .getTag, tagId)
    }

    public func getTags(
        query: TagQuery
    ) async throws -> SearchResult<TagPreview> {
        try await connect().request(event: .getTags, query)
    }

    public func movePostObject(
        postId: UUID,
        oldIndex: UInt32,
        newIndex: UInt32
    ) async throws {
        try await connect()
            .send(event: .movePostObject, postId, oldIndex, newIndex)
    }

    public func movePostObjects(
        postId: UUID,
        objects: [UUID],
        destination: UUID?
    ) async throws -> Date {
        try await connect().request(
            event: .movePostObjects,
            postId,
            objects,
            destination
        )
    }

    public func setCommentContent(
        commentId: UUID,
        content: String
    ) async throws -> String {
        try await connect()
            .request(event: .setCommentContent, commentId, content)
    }

    public func setPostDescription(
        postId: UUID,
        description: String
    ) async throws -> Modification<String?> {
        try await connect()
            .request(event: .setPostDescription, postId, description)
    }

    public func setPostTitle(
        postId: UUID,
        title: String
    ) async throws -> Modification<String?> {
        try await connect().request(event: .setPostTitle, postId, title)
    }

    public func setTagDescription(
        tagId: UUID,
        description: String
    ) async throws -> String? {
        try await connect()
            .request(event: .setTagDescription, tagId, description)
    }

    public func setTagName(
        tagId: UUID,
        newName: String
    ) async throws -> TagName {
        try await connect().request(event: .setTagName, tagId, newName)
    }
}
