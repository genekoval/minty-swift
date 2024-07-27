import Foundation

public protocol MintyRepo {
    var url: URL { get }

    func about() async throws -> About

    func addComment(post: Post.ID, content: String) async throws -> CommentData

    func addObject(file: URL) async throws -> ObjectPreview

    func addPostTag(post: Post.ID, tag: Tag.ID) async throws

    func addRelatedPost(post: Post.ID, related: Post.ID) async throws

    func addTag(name: String) async throws -> Tag.ID

    func addTagAlias(tag: Tag.ID, alias: String) async throws -> ProfileName

    func addTagSource(tag: Tag.ID, url: URL) async throws -> Source

    func addUserAlias(_ alias: String) async throws -> ProfileName

    func addUserSource(_ url: URL) async throws -> Source

    func appendPostObjects(
        post: Post.ID,
        objects: [Object.ID]
    ) async throws -> Date

    func authenticate(_ login: Login) async throws -> UUID

    func authenticate(id: UUID) async throws

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

    func deleteTagAlias(id: Tag.ID, alias: String) async throws -> ProfileName

    func deleteTagSource(id: Tag.ID, source: Source.ID) async throws

    func deleteUser() async throws

    func deleteUserAlias(_ alias: String) async throws -> ProfileName

    func deleteUserSource(id: Source.ID) async throws

    func download(object: Object.ID) async throws -> URL

    func download(object: Object.ID, to destination: URL) async throws

    func getAuthenticatedUser() async throws -> User

    func getComment(id: Comment.ID) async throws -> Comment

    func getComments(for post: Post.ID) async throws -> [CommentData]

    func getInviter(invitation: String) async throws -> User

    func getObject(id: Object.ID) async throws -> Object

    func getPost(id: Post.ID) async throws -> Post

    func getPosts(query: PostQuery) async throws -> SearchResult<PostPreview>

    func getTag(id: Tag.ID) async throws -> Tag

    func getTags(query: ProfileQuery) async throws -> SearchResult<TagPreview>

    func getUser(id: User.ID) async throws -> User

    func getUsers(query: ProfileQuery) async throws -> SearchResult<UserPreview>

    func grantAdmin(user id: UUID) async throws

    func insertPostObjects(
        id: Post.ID,
        objects: [Object.ID],
        before destination: Object.ID
    ) async throws -> Date

    func invite() async throws -> String

    func publishPost(id: Post.ID) async throws

    func reply(
        to parent: Comment.ID,
        content: String
    ) async throws -> CommentData

    func revokeAdmin(user id: UUID) async throws

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

    func setTagName(id: Tag.ID, name: String) async throws -> ProfileName

    func setUserDescription(_ description: String) async throws -> String

    func setUserEmail(_ email: String) async throws

    func setUserName(_ name: String) async throws -> ProfileName

    func setUserPassword(_ password: String) async throws

    func signOut(keepingPassword: Bool) async throws

    func signUp(_ info: SignUp, invitation: String?) async throws -> UUID
}
