import Foundation

public protocol MintyRepo {
    var version: String { get }

    func addComment(post: UUID, content: String) async throws -> Comment

    func addObject(file: URL) async throws -> ObjectPreview

    func addObjects(url: String) async throws -> [ObjectPreview]

    func add(post: UUID, objects: [UUID]) async throws -> Date

    func addPostTag(post: UUID, tag: UUID) async throws

    func addRelatedPost(post: UUID, related: UUID) async throws

    func addTag(name: String) async throws -> UUID

    func addTagAlias(tag: UUID, alias: String) async throws -> TagName

    func addTagSource(tag: UUID, url: String) async throws -> Source

    func createPost(draft: UUID) async throws

    func createPostDraft() async throws -> UUID

    func delete(post: UUID) async throws

    func delete(post: UUID, objects: [UUID]) async throws -> Date

    func delete(post: UUID, tag: UUID) async throws

    func delete(post: UUID, related: UUID) async throws

    func delete(tag: UUID) async throws

    func delete(tag: UUID, alias: String) async throws -> TagName

    func delete(tag: UUID, source: Int64) async throws

    func download(object: UUID) async throws -> URL

    func download(object: UUID, destination: URL) async throws

    func get(comment: UUID) async throws -> CommentDetail

    func getComments(for post: UUID) async throws -> [Comment]

    func get(object: UUID) async throws -> Object

    func get(post: UUID) async throws -> Post

    func getPosts(query: PostQuery) async throws -> SearchResult<PostPreview>

    func getServerInfo() async throws -> ServerInfo

    func get(tag: UUID) async throws -> Tag

    func getTags(query: TagQuery) async throws -> SearchResult<TagPreview>

    func insert(
        post: UUID,
        objects: [UUID],
        before destination: UUID
    ) async throws -> Date

    func reply(to parent: UUID, content: String) async throws -> Comment

    func set(comment: UUID, content: String) async throws -> String

    func set(
        post: UUID,
        description: String
    ) async throws -> Modification<String?>

    func set(post: UUID, title: String) async throws -> Modification<String?>

    func set(tag: UUID, description: String) async throws -> String?

    func set(tag: UUID, name: String) async throws -> TagName
}
