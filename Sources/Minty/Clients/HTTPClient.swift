import Foundation
import SwiftHTTP

private let decodeFailed = "<error message could not be decoded>"

private extension ErrorData {
    func toOptionalString() -> String? {
        switch self {
        case .none: return nil
        case .data(let data): if data.isEmpty {
            return nil
        } else {
            return decodeFailed
        }
        case .string(let message): return message
        }
    }

    func toString() -> String {
        toOptionalString() ?? decodeFailed
    }
}

private extension Formatter {
    static let customISO8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        return formatter
    }()
}

private extension JSONDecoder.DateDecodingStrategy {
    static let iso8601WithFractionalSeconds = custom { decoder in
        let string = try decoder.singleValueContainer().decode(String.self)

        guard let date = Formatter.customISO8601DateFormatter.date(from: string)
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Invalid date"
            ))
        }

        return date
   }
}

private func mapMintyError(_ error: any Swift.Error) -> MintyError {
    guard let error = error as? Error else {
        return .other(message: "\(error)")
    }

    switch error {
    case Error.generic(let message):
        return .other(message: message)
    case Error.authenticationFailure(let cause):
        return .other(message: "Authentication failure: \(cause)")
    case Error.networkError(let cause):
        return .networkError(cause: cause)
    case Error.badResponse(let response, let data):
        let status = response.statusCode

        switch status {
        case 400: return .invalidData(message: data.toString())
        case 401: return .unauthenticated(message: data.toOptionalString())
        case 404: return .parseNotFound(message: data.toString())
        case 409: return .alreadyExists(message: data.toString())
        case 500: return .serverError
        default: return .other(message:
            "Bad response from server (\(status)): \(data.toString())"
        )}
    case Error.invalidURL:
        return .other(message: "Bad URL")
    }
}

private struct RequestWrapper {
    private let request: Request

    init(_ request: Request) {
        self.request = request
    }

    @discardableResult
    func query<T>(name: String, value: T?) -> Self 
    where T: CustomStringConvertible {
        .init(request.query(name: name, value: value))
    }

    @discardableResult
    func body(_ data: String) -> Self {
        .init(request.body(data))
    }

    @discardableResult
    func encode<T: Encodable>(_ value: T) throws -> Self {
        .init(try request.encode(value))
    }

    @discardableResult
    func file(_ file: URL) -> Self {
        .init(request.file(file))
    }

    @discardableResult
    func form(_ text: String) -> Self {
        return .init(request.body(
            text,
            contentType: "application/x-www-form-urlencoded"
        ))
    }

    @discardableResult
    func query(name: String, value: [UUID]) -> Self {
        .init(request.query(
            name: name,
            value: value.map { $0.uuidString }.joined(separator: ",")
        ))
    }

    func download() async throws -> URL {
        do {
            return try await request.download()
        }
        catch {
            throw mapMintyError(error)
        }
    }

    func send() async throws {
        do {
            try await request.send()
        }
        catch {
            throw mapMintyError(error)
        }
    }

    func send<T>(
        authenticate: Bool = true
    ) async throws -> T where T : Decodable {
        do {
            return try await request.send(authenticate: authenticate)
        }
        catch {
            throw mapMintyError(error)
        }
    }

    func date() async throws -> Date {
        let text: String = try await send()

        guard let date = Formatter.customISO8601DateFormatter.date(from: text)
        else {
            throw MintyError.other(
                message: "Received invalid date from server: \(text)"
            )
        }

        return date
    }

    func uuid(authenticate: Bool = true) async throws -> UUID {
        let text: String = try await send(authenticate: authenticate)

        guard let uuid = UUID(uuidString: text) else {
            throw MintyError.other(
                message: "Received invalid UUID from server: \(text)"
            )
        }

        return uuid
    }
}

private struct ClientWrapper {
    private var client: Client

    var session: URLSession {
        client.session
    }

    init?(
        baseURL: URL,
        session: URLSession,
        credentialPersistence: URLCredential.Persistence
    ) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        guard let client = Client(
            baseURL: baseURL,
            session: session,
            credentialPersistence: credentialPersistence,
            decoder: decoder,
            encoder: encoder
        ) else {
            return nil
        }

        self.client = client
    }

    mutating func delegate(_ value: Delegate) {
        client.delegate = value
    }

    func delete(_ path: String) -> RequestWrapper {
        request(method: "DELETE", path: path)
    }

    func get(_ path: String) -> RequestWrapper {
        request(method: "GET", path: path)
    }

    func post(_ path: String) -> RequestWrapper {
        request(method: "POST", path: path)
    }

    func put(_ path: String) -> RequestWrapper {
        request(method: "PUT", path: path)
    }

    private func request(method: String, path: String) -> RequestWrapper {
        .init(client.request(method: method, path: path))
    }

    func password(for user: UUID) -> String? {
        client.password(for: user.uuidString)
    }

    func storeCredential(for user: UUID, password: String) {
        client.storeCredential(for: user.uuidString, password: password)
    }

    func removeCredential(for user: UUID) {
        client.removeCredential(for: user.uuidString)
    }
}

private struct Delegate: ClientDelegate {
    weak var client: HTTPClient?

    func needsAuthentication(response: HTTPURLResponse) -> String? {
        guard response.statusCode == 401 else { return nil }
        return client?.user?.uuidString
    }

    func authenticate(with credential: URLCredential) async throws -> Bool {
        guard let client = client,
              let user = credential.user,
              let password = credential.password,
              let id = UUID(uuidString: user),
              let email = client.emails[id]
        else {
            return false
        }

        let login = Login(email: email, password: password)
        try await client.authenticatePriv(login)

        return true
    }
}

public final class HTTPClient: MintyRepo {
    public let url: URL
    public let user: UUID?
    public let emails: [UUID: String]

    private var client: ClientWrapper

    public init?(
        baseURL: URL,
        user: UUID? = nil,
        emails: [UUID: String] = [:],
        session: URLSession = .shared,
        credentialPersistence: URLCredential.Persistence = .permanent
    ) {
        guard let client = ClientWrapper(
            baseURL: baseURL,
            session: session,
            credentialPersistence: credentialPersistence
        )
        else { return nil }

        url = baseURL
        self.user = user
        self.emails = emails
        self.client = client

        self.client.delegate(Delegate(client: self))
    }

    public func about() async throws -> About {
        try await client
            .get("/")
            .send()
    }

    public func addComment(
        post: Post.ID,
        content: String
    ) async throws -> CommentData {
        try await client
            .post("/comments/\(post)")
            .body(content)
            .send()
    }

    public func addObject(file: URL) async throws -> ObjectPreview {
        try await client
            .post("/object")
            .file(file)
            .send()
    }

    public func addPostTag(post: Post.ID, tag: Tag.ID) async throws {
        try await client
            .put("/post/\(post)/tag/\(tag)")
            .send()
    }

    public func addRelatedPost(post: Post.ID, related: Post.ID) async throws {
        try await client
            .put("/post/\(post)/related/\(related)")
            .send()
    }

    public func addTag(name: String) async throws -> Tag.ID {
        try await client
            .post("/tag/\(name)")
            .uuid()
    }

    public func addTagAlias(
        tag: Tag.ID,
        alias: String
    ) async throws -> ProfileName {
        try await client
            .put("/tag/\(tag)/name/\(alias)")
            .send()
    }

    public func addTagSource(tag: Tag.ID, url: URL) async throws -> Source {
        try await client
            .post("/tag/\(tag)/source")
            .encode(url)
            .send()
    }

    public func addUserAlias(_ alias: String) async throws -> ProfileName {
        try await client
            .put("/user/name/\(alias)")
            .send()
    }

    public func addUserSource(_ url: URL) async throws -> Source {
        try await client
            .post("/user/source")
            .encode(url)
            .send()
    }

    public func appendPostObjects(
        post: Post.ID,
        objects: [Object.ID]
    ) async throws -> Date {
        try await client
            .post("/post/\(post)/objects")
            .encode(objects)
            .date()
    }

    public func authenticate(_ login: Login) async throws -> UUID {
        let id = try await authenticatePriv(login)

        client.storeCredential(for: id, password: login.password)

        return id
    }

    public func authenticate(id: UUID) async throws {
        guard let email = emails[id],
              let password = client.password(for: id)
        else {
            return
        }

        let login = Login(email: email, password: password)
        _ = try await authenticatePriv(login)
    }

    @discardableResult
    func authenticatePriv(_ login: Login) async throws -> UUID {
        try await client
            .post("/user/session")
            .encode(login)
            .uuid(authenticate: false)
    }

    public func createPost(parts: PostParts) async throws -> Post.ID {
        try await client
            .post("/post")
            .encode(parts)
            .uuid()
    }

    public func deleteComment(id: Comment.ID, recursive: Bool) async throws {
        let request = client.delete("/comment/\(id)")
        if recursive { request.query(name: "recursive", value: recursive) }
        return try await request.send()
    }

    public func deletePost(id: Post.ID) async throws {
        try await client
            .delete("/post/\(id)")
            .send()
    }

    public func deletePostObjects(
        id: Post.ID,
        objects: [Object.ID]
    ) async throws -> Date {
        try await client
            .delete("/post/\(id)/objects")
            .encode(objects)
            .date()
    }

    public func deletePostTag(id: Post.ID, tag: Tag.ID) async throws {
        try await client
            .delete("/post/\(id)/tag/\(tag)")
            .send()
    }

    public func deleteRelatedPost(id: Post.ID, related: Post.ID) async throws {
        try await client
            .delete("/post/\(id)/related/\(related)")
            .send()
    }

    public func deleteTag(id: Tag.ID) async throws {
        try await client.delete("/tag/\(id)").send()
    }

    public func deleteTagAlias(
        id: Tag.ID,
        alias: String
    ) async throws -> ProfileName {
        try await client
            .delete("/tag/\(id)/name/\(alias)")
            .send()
    }

    public func deleteTagSource(id: Tag.ID, source: Source.ID) async throws {
        try await client
            .delete("/tag/\(id)/source/\(source)")
            .send()
    }

    public func deleteUser() async throws {
        try await client.delete("/user").send()

        if let user {
            client.removeCredential(for: user)
        }
    }

    public func deleteUserAlias(_ alias: String) async throws -> ProfileName {
        try await client
            .delete("/user/name/\(alias)")
            .send()
    }

    public func deleteUserSource(id: Source.ID) async throws {
        try await client
            .delete("/user/source/\(id)")
            .send()
    }

    public func download(object: Object.ID) async throws -> URL {
        try await client
            .get("/object/\(object)/data")
            .download()
    }

    public func download(object: Object.ID, to destination: URL) async throws {
        let location = try await download(object: object)
        try FileManager.default.moveItem(at: location, to: destination)
    }

    public func getAuthenticatedUser() async throws -> User {
        try await client.get("/user").send()
    }

    public func getComment(id: Comment.ID) async throws -> Comment {
        try await client
            .get("/comment/\(id)")
            .send()
    }

    public func getComments(for post: Post.ID) async throws -> [CommentData] {
        try await client
            .get("/comments/\(post)")
            .send()
    }

    public func getInviter(invitation: String) async throws -> User {
        try await client.get("/invitation/\(invitation)").send()
    }

    public func getObject(id: Object.ID) async throws -> Object {
        try await client
            .get("/object/\(id)")
            .send()
    }

    public func getPost(id: Post.ID) async throws -> Post {
        try await client
            .get("/post/\(id)")
            .send()
    }

    public func getPosts(
        query: PostQuery
    ) async throws -> SearchResult<PostPreview> {
        let request = client
            .get("/posts")
            .query(name: "size", value: query.size)

        if query.from > 0 { request.query(name: "from", value: query.from) }

        if !query.text.isEmpty {
            request.query(name: "q", value: query.text)
        }

        if let poster = query.poster {
            request.query(name: "u", value: poster)
        }

        if !query.tags.isEmpty {
            request.query(name: "tags", value: query.tags)
        }

        if query.visibility != .pub {
            request.query(name: "vis", value: query.visibility)
        }

        if query.sort != .created {
            request.query(name: "sort", value: query.sort.value.rawValue)
            request.query(name: "order", value: query.sort.order.rawValue)
        }

        return try await request.send()
    }

    public func getTag(id: Tag.ID) async throws -> Tag {
        try await client
            .get("/tag/\(id)")
            .send()
    }

    public func getTags(
        query: ProfileQuery
    ) async throws -> SearchResult<TagPreview> {
        let request = client
            .get("/tags")
            .query(name: "name", value: query.name)
            .query(name: "size", value: query.size)

        if query.from > 0 { request.query(name: "from", value: query.from) }

        if !query.exclude.isEmpty {
            request.query(name: "exclude", value: query.exclude)
        }

        return try await request.send()
    }

    public func getUser(id: User.ID) async throws -> User {
        try await client.get("/user/\(id)").send()
    }

    public func getUsers(
        query: ProfileQuery
    ) async throws -> SearchResult<UserPreview> {
        let request = client
            .get("/users")
            .query(name: "name", value: query.name)
            .query(name: "size", value: query.size)

        if query.from > 0 { request.query(name: "from", value: query.from) }

        if !query.exclude.isEmpty {
            request.query(name: "exclude", value: query.exclude)
        }

        return try await request.send()
    }

    public func grantAdmin(user id: UUID) async throws {
        try await client
            .put("/user/\(id)/admin")
            .send()
    }

    public func insertPostObjects(
        id: Post.ID,
        objects: [Object.ID],
        before destination: Object.ID
    ) async throws -> Date {
        try await client
            .post("/post/\(id)/objects/\(destination)")
            .encode(objects)
            .date()
    }

    public func invite() async throws -> String {
        try await client.get("/invitation").send()
    }
    
    public func password(for user: UUID) -> String? {
        client.password(for: user)
    }

    public func publishPost(id: Post.ID) async throws {
        try await client
            .put("/post/\(id)")
            .send()
    }

    public func reply(
        to parent: Comment.ID,
        content: String
    ) async throws -> CommentData {
        try await client
            .post("/comment/\(parent)")
            .body(content)
            .send()
    }

    public func revokeAdmin(user id: UUID) async throws {
        try await client
            .delete("/user/\(id)/admin")
            .send()
    }

    public func setCommentContent(
        id: Comment.ID,
        content: String
    ) async throws -> String {
        try await client
            .put("/comment/\(id)")
            .body(content)
            .send()
    }

    public func setPostDescription(
        id: Post.ID,
        description: String
    ) async throws -> Modification<String> {
        try await client
            .put("/post/\(id)/description")
            .body(description)
            .send()
    }

    public func setPostTitle(
        id: Post.ID,
        title: String
    ) async throws -> Modification<String> {
        try await client
            .put("/post/\(id)/title")
            .body(title)
            .send()
    }

    public func setTagDescription(
        id: Tag.ID,
        description: String
    ) async throws -> String {
        try await client
            .put("/tag/\(id)/description")
            .body(description)
            .send()
    }

    public func setTagName(
        id: Tag.ID,
        name: String
    ) async throws -> ProfileName {
        try await client
            .put("/tag/\(id)/name/\(name)")
            .query(name: "main", value: true)
            .send()
    }

    public func setUserDescription(
        _ description: String
    ) async throws -> String {
        try await client
            .put("/user/description")
            .body(description)
            .send()
    }

    public func setUserEmail(_ email: String) async throws {
        try await client
            .put("/user/email")
            .body(email)
            .send()
    }

    public func setUserName(_ name: String) async throws -> ProfileName {
        try await client
            .put("/user/name/\(name)")
            .query(name: "main", value: true)
            .send()
    }

    public func setUserPassword(_ password: String) async throws {
        try await client
            .put("/user/password")
            .body(password)
            .send()

        if let user {
            client.storeCredential(for: user, password: password)
        }
    }

    public func signOut(keepingPassword: Bool) async throws {
        try await client.delete("/user/session").send()

        if let user, !keepingPassword {
            client.removeCredential(for: user)
        }
    }

    public func signUp(
        _ info: SignUp,
        invitation: String?
    ) async throws -> UUID {
        let request = client.post("/signup")

        guard let username = info
            .username
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            throw MintyError.invalidData(message: "invalid username")
        }

        guard let email = info
            .email
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            throw MintyError.invalidData(message: "invalid email")
        }

        guard let password = info
            .password
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            throw MintyError.invalidData(message: "invalid password")
        }

        let body = "username=\(username)&email=\(email)&password=\(password)"
        request.form(body)

        if let invitation {
            request.query(name: "invitation", value: invitation)
        }

        let id = try await request.uuid()

        client.storeCredential(for: id, password: info.password)

        return id
    }
}
