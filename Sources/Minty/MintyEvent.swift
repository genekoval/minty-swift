import Zipline

enum MintyEvent: UInt32, ZiplineEncodable {
    case addComment
    case addObjectData
    case addObjectLocal
    case addObjectsUrl
    case addPost
    case addPostObjects
    case addPostTag
    case addTag
    case addTagAlias
    case addTagSource
    case deletePost
    case deletePostObjects
    case deletePostTag
    case deleteTag
    case deleteTagAlias
    case deleteTagSource
    case getComments
    case getObject
    case getPost
    case getPosts
    case getServerInfo
    case getTag
    case getTags
    case movePostObject
    case setCommentContent
    case setPostDescription
    case setPostTitle
    case setTagDescription
    case setTagName

    public func encode(to encoder: ZiplineEncoder) {
        rawValue.encode(to: encoder)
    }
}