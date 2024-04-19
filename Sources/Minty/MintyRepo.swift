import Foundation

public protocol MintyRepo {
    func about() async throws -> About

    func addComment(post: Post.ID, content: String) async throws -> CommentData

    func addObject(file: URL) async throws -> ObjectPreview

    func addPostTag(post: Post.ID, tag: Tag.ID) async throws

    func addRelatedPost(post: Post.ID, related: Post.ID) async throws

    func addTag(name: String) async throws -> Tag.ID

    func addTagAlias(tag: Tag.ID, alias: String) async throws -> TagName

    func addTagSource(tag: Tag.ID, url: URL) async throws -> Source

    func appendPostObjects(
        post: Post.ID,
        objects: [Object.ID]
    ) async throws -> Date

    func createPost(parts: PostParts) async throws -> Post.ID

    func deleteComment(id: Comment.ID, recursive: Bool) async throws

    func deletePost(id: Post.ID) async throws

    func deletePostObjects(
        id: Post.ID,
        objects: [Object.ID]
    ) async throws -> Date

    func deletePostTag(id: Post.ID, tag: Tag.ID) async throws

    func deleteRelatedPost(id: Post.ID, related: Post.ID) async throws

    func deleteTag(id: Tag.ID) async throws

    func deleteTagAlias(id: Tag.ID, alias: String) async throws -> TagName

    func deleteTagSource(id: Tag.ID, source: Source.ID) async throws

    func download(object: Object.ID) async throws -> URL

    func download(object: Object.ID, to destination: URL) async throws

    func getComment(id: Comment.ID) async throws -> Comment

    func getComments(for post: Post.ID) async throws -> [CommentData]

    func getObject(id: Object.ID) async throws -> Object

    func getPost(id: Post.ID) async throws -> Post

    func getPosts(query: PostQuery) async throws -> SearchResult<PostPreview>

    func getTag(id: Tag.ID) async throws -> Tag

    func getTags(query: TagQuery) async throws -> SearchResult<TagPreview>

    func insertPostObjects(
        id: Post.ID,
        objects: [Object.ID],
        before destination: Object.ID
    ) async throws -> Date

    func publishPost(id: Post.ID) async throws

    func reply(
        to parent: Comment.ID,
        content: String
    ) async throws -> CommentData

    func setCommentContent(
        id: Comment.ID,
        content: String
    ) async throws -> String

    func setPostDescription(
        id: Post.ID,
        description: String
    ) async throws -> Modification<String>

    func setPostTitle(
        id: Post.ID,
        title: String
    ) async throws -> Modification<String>

    func setTagDescription(
        id: Tag.ID,
        description: String
    ) async throws -> String

    func setTagName(id: Tag.ID, name: String) async throws -> TagName
}
