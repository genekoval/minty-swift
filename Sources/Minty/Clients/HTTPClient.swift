import Foundation
import SwiftHTTP

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

private extension Request {
    @discardableResult
    func query(name: String, value: [UUID]) -> Self {
        query(
            name: name,
            value: value.map { $0.uuidString }.joined(separator: ",")
        )
    }

    func download2() async throws -> URL {
        do {
            return try await download()
        }
        catch {
            throw mapMintyError(error)
        }
    }

    func send2() async throws {
        do {
            try await send()
        }
        catch {
            throw mapMintyError(error)
        }
    }

    func send2<T>() async throws -> T where T : Decodable {
        do {
            return try await send()
        }
        catch {
            throw mapMintyError(error)
        }
    }

    func date() async throws -> Date {
        let text: String = try await send2()

        guard let date = Formatter.customISO8601DateFormatter.date(from: text)
        else {
            throw MintyError.other(
                message: "Received invalid date from server: \(text)"
            )
        }

        return date
    }

    func uuid() async throws -> UUID {
        let text: String = try await send2()

        guard let uuid = UUID(uuidString: text) else {
            throw MintyError.other(
                message: "Received invalid UUID from server: \(text)"
            )
        }

        return uuid
    }
}

private func mapMintyError(_ error: any Swift.Error) -> MintyError {
    guard let error = error as? Error else {
        return .other(message: "\(error)")
    }

    switch error {
    case Error.generic(let message):
        return .other(message: message)
    case Error.networkError(let cause):
        return .networkError(cause: cause)
    case Error.badResponse(let response, let data):
        let status = response.statusCode
        let message = if case let ErrorData.string(string) = data {
            string
        } else {
            "<error message could not be decoded>"
        }

        switch status {
        case 400: return .invalidData(message: message)
        case 404: return .parseNotFound(message: message)
        case 500: return .serverError
        default:
            return .other(
                message: "Bad response from server (\(status)): \(message)"
            )
        }
    case Error.invalidURL:
        return .other(message: "Bad URL")
    }
}

public final class HTTPClient: MintyRepo {
    private let client: Client

    public init?(baseURL: URL, session: URLSession = .shared) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        guard let client = Client(
            baseURL: baseURL,
            decoder: decoder,
            encoder: encoder
        ) else {
            return nil
        }

        self.client = client
    }

    public func about() async throws -> About {
        try await client
            .get("/")
            .send2()
    }

    public func addComment(
        post: Post.ID,
        content: String
    ) async throws -> CommentData {
        try await client
            .post("/comments/\(post)")
            .body(content)
            .send2()
    }

    public func addObject(file: URL) async throws -> ObjectPreview {
        try await client
            .post("/object")
            .file(file)
            .send2()
    }

    public func addPostTag(post: Post.ID, tag: Tag.ID) async throws {
        try await client
            .put("/post/\(post)/tag/\(tag)")
            .send2()
    }

    public func addRelatedPost(post: Post.ID, related: Post.ID) async throws {
        try await client
            .put("/post/\(post)/related/\(related)")
            .send2()
    }

    public func addTag(name: String) async throws -> Tag.ID {
        try await client
            .post("/tag/\(name)")
            .uuid()
    }

    public func addTagAlias(
        tag: Tag.ID,
        alias: String
    ) async throws -> TagName {
        try await client
            .put("/tag/\(tag)/name/\(alias)")
            .send2()
    }

    public func addTagSource(tag: Tag.ID, url: URL) async throws -> Source {
        try await client
            .post("/tag/\(tag)/source")
            .encode(url)
            .send2()
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

    public func createPost(parts: PostParts) async throws -> Post.ID {
        try await client
            .post("/post")
            .encode(parts)
            .uuid()
    }

    public func deleteComment(id: Comment.ID, recursive: Bool) async throws {
        let request = client.delete("/comment/\(id)")
        if recursive { request.query(name: "recursive", value: recursive) }
        return try await request.send2()
    }

    public func deletePost(id: Post.ID) async throws {
        try await client
            .delete("/post/\(id)")
            .send2()
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
            .send2()
    }

    public func deleteRelatedPost(id: Post.ID, related: Post.ID) async throws {
        try await client
            .delete("/post/\(id)/related/\(related)")
            .send2()
    }

    public func deleteTag(id: Tag.ID) async throws {
        try await client.delete("/tag/\(id)").send2()
    }

    public func deleteTagAlias(
        id: Tag.ID,
        alias: String
    ) async throws -> TagName {
        try await client
            .delete("/tag/\(id)/name/\(alias)")
            .send2()
    }

    public func deleteTagSource(id: Tag.ID, source: Source.ID) async throws {
        try await client
            .delete("/tag/\(id)/source/\(source)")
            .send2()
    }

    public func download(object: Object.ID) async throws -> URL {
        try await client
            .get("/object/\(object)/data")
            .download2()
    }

    public func download(object: Object.ID, to destination: URL) async throws {
        let location = try await download(object: object)
        try FileManager.default.moveItem(at: location, to: destination)
    }

    public func getComment(id: Comment.ID) async throws -> Comment {
        try await client
            .get("/comment/\(id)")
            .send2()
    }

    public func getComments(for post: Post.ID) async throws -> [CommentData] {
        try await client
            .get("/comments/\(post)")
            .send2()
    }

    public func getObject(id: Object.ID) async throws -> Object {
        try await client
            .get("/object/\(id)")
            .send2()
    }

    public func getPost(id: Post.ID) async throws -> Post {
        try await client
            .get("/post/\(id)")
            .send2()
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

        return try await request.send2()
    }

    public func getTag(id: Tag.ID) async throws -> Tag {
        try await client
            .get("/tag/\(id)")
            .send2()
    }

    public func getTags(
        query: TagQuery
    ) async throws -> SearchResult<TagPreview> {
        let request = client
            .get("/tags")
            .query(name: "name", value: query.name)
            .query(name: "size", value: query.size)

        if query.from > 0 { request.query(name: "from", value: query.from) }

        if !query.exclude.isEmpty {
            request.query(name: "exclude", value: query.exclude)
        }

        return try await request.send2()
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

    public func publishPost(id: Post.ID) async throws {
        try await client
            .put("/post/\(id)")
            .send2()
    }

    public func reply(
        to parent: Comment.ID,
        content: String
    ) async throws -> CommentData {
        try await client
            .post("/comment/\(parent)")
            .body(content)
            .send2()
    }

    public func setCommentContent(
        id: Comment.ID,
        content: String
    ) async throws -> String {
        try await client
            .put("/comment/\(id)")
            .body(content)
            .send2()
    }

    public func setPostDescription(
        id: Post.ID,
        description: String
    ) async throws -> Modification<String> {
        try await client
            .put("/post/\(id)/description")
            .body(description)
            .send2()
    }

    public func setPostTitle(
        id: Post.ID,
        title: String
    ) async throws -> Modification<String> {
        try await client
            .put("/post/\(id)/title")
            .body(title)
            .send2()
    }

    public func setTagDescription(
        id: Tag.ID,
        description: String
    ) async throws -> String {
        try await client
            .put("/tag/\(id)/description")
            .body(description)
            .send2()
    }

    public func setTagName(id: Tag.ID, name: String) async throws -> TagName {
        try await client
            .put("/tag/\(id)/name/\(name)")
            .query(name: "main", value: true)
            .send2()
    }
}
