import Zipline

enum MintyEvent: UInt32, ZiplineEncodable {
    case addComment
    case addObjectData
    case addObjectLocal
    case addObjectsUrl
    case addPost
    case addPostObjects
    case addPostTag
    case addRelatedPost
    case addReply
    case addTag
    case addTagAlias
    case addTagSource
    case deletePost
    case deletePostObjects
    case deletePostObjectsRanges
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
    case movePostObject
    case movePostObjects
    case setCommentContent
    case setPostDescription
    case setPostTitle
    case setTagDescription
    case setTagName

    public func encode(to encoder: ZiplineEncoder) {
        rawValue.encode(to: encoder)
    }
}
