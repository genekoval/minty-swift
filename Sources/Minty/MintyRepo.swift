import Foundation
import Zipline

public protocol MintyRepo {
    func addComment(postId: UUID, content: String) async throws -> Comment

    func addObjectData(
        size: Int,
        writer: @escaping (DataWriter) async throws -> Void
    ) async throws -> ObjectPreview

    func addObjectsUrl(url: String) async throws -> [ObjectPreview]

    func addPostObjects(
        postId: UUID,
        objects: [UUID],
        destination: UUID?
    ) async throws -> Date

    func addPostTag(postId: UUID, tagId: UUID) async throws

    func addRelatedPost(postId: UUID, related: UUID) async throws

    func addReply(parentId: UUID, content: String) async throws -> Comment

    func addTag(name: String) async throws -> UUID

    func addTagAlias(tagId: UUID, alias: String) async throws -> TagName

    func addTagSource(tagId: UUID, url: String) async throws -> Source

    func createPost(postId: UUID) async throws

    func createPostDraft() async throws -> UUID

    func deletePost(postId: UUID) async throws

    func deletePostObjects(postId: UUID, objects: [UUID]) async throws -> Date

    func deletePostTag(postId: UUID, tagId: UUID) async throws

    func deleteRelatedPost(postId: UUID, related: UUID) async throws

    func deleteTag(tagId: UUID) async throws

    func deleteTagAlias(tagId: UUID, alias: String) async throws -> TagName

    func deleteTagSource(tagId: UUID, sourceId: Int64) async throws

    func getComment(commentId: UUID) async throws -> CommentDetail

    func getComments(postId: UUID) async throws -> [Comment]

    func getObject(objectId: UUID) async throws -> Object

    func getObjectData(
        objectId: UUID,
        handler: (Data) async throws -> Void
    ) async throws

    func getPost(postId: UUID) async throws -> Post

    func getPosts(query: PostQuery) async throws -> SearchResult<PostPreview>

    func getServerInfo() async throws -> ServerInfo

    func getTag(tagId: UUID) async throws -> Tag

    func getTags(query: TagQuery) async throws -> SearchResult<TagPreview>

    func movePostObjects(
        postId: UUID,
        objects: [UUID],
        destination: UUID?
    ) async throws -> Date

    func setCommentContent(
        commentId: UUID,
        content: String
    ) async throws -> String

    func setPostDescription(
        postId: UUID,
        description: String
    ) async throws -> Modification<String?>

    func setPostTitle(
        postId: UUID,
        title: String
    ) async throws -> Modification<String?>

    func setTagDescription(
        tagId: UUID,
        description: String
    ) async throws -> String?

    func setTagName(tagId: UUID, newName: String) async throws -> TagName
}
