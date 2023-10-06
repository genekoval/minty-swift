import Foundation

public protocol MintyRepo {
    var version: String { get }

    func addComment(post: Post.ID, content: String) async throws -> Comment

    func addObject(file: URL) async throws -> ObjectPreview

    func addObjects(url: String) async throws -> [ObjectPreview]

    func add(post: Post.ID, objects: [Object.ID]) async throws -> Date

    func addPostTag(post: Post.ID, tag: Tag.ID) async throws

    func addRelatedPost(post: Post.ID, related: Post.ID) async throws

    func addTag(name: String) async throws -> Tag.ID

    func addTagAlias(tag: Tag.ID, alias: String) async throws -> TagName

    func addTagSource(tag: Tag.ID, url: String) async throws -> Source

    func createPost(draft: Post.ID) async throws

    func createPostDraft() async throws -> Post.ID

    func delete(comment: CommentDetail.ID, recursive: Bool) async throws -> Bool

    func delete(post: Post.ID) async throws

    func delete(post: Post.ID, objects: [Object.ID]) async throws -> Date

    func delete(post: Post.ID, tag: Tag.ID) async throws

    func delete(post: Post.ID, related: Post.ID) async throws

    func delete(tag: Tag.ID) async throws

    func delete(tag: Tag.ID, alias: String) async throws -> TagName

    func delete(tag: Tag.ID, source: Source.ID) async throws

    func download(object: Object.ID) async throws -> URL

    func download(object: Object.ID, destination: URL) async throws

    func get(comment: CommentDetail.ID) async throws -> CommentDetail?

    func getComments(for post: Post.ID) async throws -> [Comment]

    func get(object: Object.ID) async throws -> Object?

    func get(post: Post.ID) async throws -> Post?

    func getPosts(query: PostQuery) async throws -> SearchResult<PostPreview>

    func getServerInfo() async throws -> ServerInfo

    func get(tag: Tag.ID) async throws -> Tag?

    func getTags(query: TagQuery) async throws -> SearchResult<TagPreview>

    func insert(
        post: Post.ID,
        objects: [Object.ID],
        before destination: Object.ID
    ) async throws -> Date

    func reply(to parent: Comment.ID, content: String) async throws -> Comment

    func set(comment: Comment.ID, content: String) async throws -> String

    func set(
        post: Post.ID,
        description: String
    ) async throws -> Modification<String?>

    func set(post: Post.ID, title: String) async throws -> Modification<String?>

    func set(tag: Tag.ID, description: String) async throws -> String?

    func set(tag: Tag.ID, name: String) async throws -> TagName
}
