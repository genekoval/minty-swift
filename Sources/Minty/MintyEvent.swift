import Zipline

enum MintyEvent: UInt32, ZiplineEncodable {
    case addComment
    case addObjectData
    case addObjectsUrl
    case addPostObjects
    case addPostTag
    case addRelatedPost
    case addReply
    case addTag
    case addTagAlias
    case addTagSource
    case createPost
    case createPostDraft
    case deletePost
    case deletePostObjects
    case deletePostTag
    case deleteRelatedPost
    case deleteTag
    case deleteTagAlias
    case deleteTagSource
    case getComment
    case getComments
    case getObject
    case getPost
    case getPosts
    case getServerInfo
    case getTag
    case getTags
    case movePostObjects
    case setCommentContent
    case setPostDescription
    case setPostTitle
    case setTagDescription
    case setTagName

    public func encode(to encoder: ZiplineEncoder) async throws {
        try await rawValue.encode(to: encoder)
    }
}
