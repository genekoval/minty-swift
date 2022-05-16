import Foundation

public protocol MintyRepo {
    func addComment(postId: UUID, content: String) throws -> Comment

    func addObjectData(
        count: Int,
        data: @escaping (DataWriter) -> Void
    ) throws -> ObjectPreview

    func addObjectsUrl(url: String) throws -> [ObjectPreview]

    func addPost(parts: PostParts) throws -> UUID

    func addPostObjects(
        postId: UUID,
        objects: [UUID],
        position: Int16
    ) throws -> Date

    func addPostTag(postId: UUID, tagId: UUID) throws

    func addRelatedPost(postId: UUID, related: UUID) throws

    func addReply(parentId: UUID, content: String) throws -> Comment

    func addTag(name: String) throws -> UUID

    func addTagAlias(tagId: UUID, alias: String) throws -> TagName

    func addTagSource(tagId: UUID, url: String) throws -> Source

    func deletePost(postId: UUID) throws

    func deletePostObjects(postId: UUID, objects: [UUID]) throws -> Date

    func deletePostObjects(
        postId: UUID,
        ranges: [Range<Int32>]
    ) throws -> Date

    func deletePostTag(postId: UUID, tagId: UUID) throws

    func deleteRelatedPost(postId: UUID, related: UUID) throws

    func deleteTag(tagId: UUID) throws

    func deleteTagAlias(tagId: UUID, alias: String) throws -> TagName

    func deleteTagSource(tagId: UUID, sourceId: String) throws

    func getComments(postId: UUID) throws -> [Comment]

    func getObject(objectId: UUID) throws -> Object

    func getObjectData(objectId: UUID, handler: (Data) throws -> Void) throws

    func getPost(postId: UUID) throws -> Post

    func getPosts(query: PostQuery) throws -> SearchResult<PostPreview>

    func getServerInfo() throws -> ServerInfo

    func getTag(tagId: UUID) throws -> Tag

    func getTags(query: TagQuery) throws -> SearchResult<TagPreview>

    func movePostObject(
        postId: UUID,
        oldIndex: UInt32,
        newIndex: UInt32
    ) throws

    func movePostObjects(
        postId: UUID,
        objects: [UUID],
        destination: UUID?
    ) throws -> Date

    func setCommentContent(commentId: UUID, content: String) throws -> String

    func setPostDescription(
        postId: UUID,
        description: String
    ) throws -> Modification<String?>

    func setPostTitle(
        postId: UUID,
        title: String
    ) throws -> Modification<String?>

    func setTagDescription(tagId: UUID, description: String) throws -> String?

    func setTagName(tagId: UUID, newName: String) throws -> TagName
}
