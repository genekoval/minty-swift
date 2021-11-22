import Foundation

public protocol MintyRepo {
    func addComment(
        postId: String,
        parentId: String?,
        content: String
    ) throws -> Comment

    func addObjectData(
        count: Int,
        data: @escaping (DataWriter) -> Void
    ) throws -> String

    func addObjectsUrl(url: String) throws -> [String]

    func addPost(parts: PostParts) throws -> String

    func addPostObjects(
        postId: String,
        objects: [String],
        position: UInt32
    ) throws -> [ObjectPreview]

    func addPostTag(postId: String, tagId: String) throws

    func addTag(name: String) throws -> String

    func addTagAlias(tagId: String, alias: String) throws -> TagName

    func addTagSource(tagId: String, url: String) throws -> Source

    func deletePost(postId: String) throws

    func deletePostObjects(postId: String, objects: [String]) throws

    func deletePostObjects(postId: String, ranges: [Range<Int32>]) throws

    func deletePostTag(postId: String, tagId: String) throws

    func deleteTag(tagId: String) throws

    func deleteTagAlias(tagId: String, alias: String) throws -> TagName

    func deleteTagSource(tagId: String, sourceId: String) throws

    func getComments(postId: String) throws -> [Comment]

    func getObject(objectId: String) throws -> Object

    func getObjectData(objectId: String, handler: (Data) -> Void) throws

    func getPost(postId: String) throws -> Post

    func getPosts(query: PostQuery) throws -> SearchResult<PostPreview>

    func getServerInfo() throws -> ServerInfo

    func getTag(tagId: String) throws -> Tag

    func getTags(query: TagQuery) throws -> SearchResult<TagPreview>

    func movePostObject(
        postId: String,
        oldIndex: UInt32,
        newIndex: UInt32
    ) throws

    func setCommentContent(commentId: String, content: String) throws -> String

    func setPostDescription(
        postId: String,
        description: String
    ) throws -> Modification<String?>

    func setPostTitle(
        postId: String,
        title: String
    ) throws -> Modification<String?>

    func setTagDescription(tagId: String, description: String) throws -> String?

    func setTagName(tagId: String, newName: String) throws -> TagName
}
