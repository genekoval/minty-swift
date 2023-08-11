import Foundation
import Fstore
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
}

private extension Request {
    func body(_ data: [UUID]) -> Self {
        body(data.map { $0.uuidString }.joined(separator: "\n"))
    }
}

public final class HTTPClient: MintyRepo {
    private let bucket: UUID
    private let objectStore: ObjectStore

    private let client: Client

    public let version: String

    public init?(baseURL: URL, session: URLSession = .shared) async throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        guard let client = Client(baseURL: baseURL, decoder: decoder) else {
            return nil
        }

        self.client = client

        let info: ServerInfo = try await client.get("/").send()

        self.version = info.version
        self.bucket = info.objectSource.bucketId

        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = info.objectSource.host ?? baseURL.host
        components.port = info.objectSource.port

        guard
            let url = components.url,
            let store = Fstore.HTTPClient(baseURL: url)
        else {
            throw MintyError.unspecified(
                message: "Failed to build valid object store URL: \(components)"
            )
        }

        objectStore = store
    }

    public func addComment(
        post: Post.ID,
        content: String
    ) async throws -> Comment {
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

    public func addObjects(url: String) async throws -> [ObjectPreview] {
        try await client
            .post("/object/url")
            .body(url)
            .send()
    }

    public func add(post: Post.ID, objects: [Object.ID]) async throws -> Date {
        try await client
            .post("post/\(post)/objects")
            .body(objects)
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
            .send()
    }

    public func addTagAlias(
        tag: Tag.ID,
        alias: String
    ) async throws -> TagName {
        try await client
            .put("/tag/\(tag)/name/\(alias)")
            .send()
    }

    public func addTagSource(tag: Tag.ID, url: String) async throws -> Source {
        try await client
            .post("/tag/\(tag)/source")
            .body(url)
            .send()
    }

    public func createPost(draft: Post.ID) async throws {
        try await client.put("/post/\(draft)").send()
    }

    public func createPostDraft() async throws -> Post.ID {
        try await client.post("/post").send()
    }

    public func delete(post: Post.ID) async throws {
        try await client.delete("/post/\(post)").send()
    }

    public func delete(
        post: Post.ID,
        objects: [Object.ID]
    ) async throws -> Date {
        try await client
            .delete("/post/\(post)/objects")
            .body(objects)
            .send()
    }

    public func delete(post: Post.ID, tag: Tag.ID) async throws {
        try await client
            .delete("/post/\(post)/tag/\(tag)")
            .send()
    }

    public func delete(post: Post.ID, related: Post.ID) async throws {
        try await client
            .delete("/post/\(post)/related/\(related)")
            .send()
    }

    public func delete(tag: Tag.ID) async throws {
        try await client.delete("/tag/\(tag)").send()
    }

    public func delete(tag: Tag.ID, alias: String) async throws -> TagName {
        try await client
            .delete("/tag/\(tag)/name/\(alias)")
            .send()
    }

    public func delete(tag: Tag.ID, source: Source.ID) async throws {
        try await client
            .delete("/tag/\(tag)/source/\(source)")
            .send()
    }

    public func download(object: Object.ID) async throws -> URL {
        try await objectStore.downloadObject(bucket: bucket, object: object)
    }

    public func download(object: Object.ID, destination: URL) async throws {
        try await objectStore.downloadObject(
            bucket: bucket,
            object: object,
            destination: destination
        )
    }

    public func get(comment: CommentDetail.ID) async throws -> CommentDetail {
        try await client
            .get("/comment/\(comment)")
            .send()
    }

    public func getComments(for post: Post.ID) async throws -> [Comment] {
        try await client
            .get("/comments/\(post)")
            .send()
    }

    public func get(object: Object.ID) async throws -> Object {
        try await client
            .get("object/\(object)")
            .send()
    }

    public func get(post: Post.ID) async throws -> Post {
        try await client
            .get("/post/\(post)")
            .send()
    }

    public func getPosts(
        query: PostQuery
    ) async throws -> SearchResult<PostPreview> {
        let request = client
            .get("/posts")
            .query(name: "size", value: query.size)

        if query.from > 0 { request.query(name: "from", value: query.from) }

        if let text = query.text { request.query(name: "q", value: text) }

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

    public func getServerInfo() async throws -> ServerInfo {
        try await client
            .get("/")
            .send()
    }

    public func get(tag: Tag.ID) async throws -> Tag {
        try await client
            .get("/tag/\(tag)")
            .send()
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

        return try await request.send()
    }

    public func insert(
        post: Post.ID,
        objects: [Object.ID],
        before destination: Object.ID
    ) async throws -> Date {
        try await client
            .post("/post/\(post)/objects/\(destination)")
            .body(objects)
            .send()
    }

    public func reply(
        to parent: Comment.ID,
        content: String
    ) async throws -> Comment {
        try await client
            .post("/comment/\(parent)")
            .body(content)
            .send()
    }

    public func set(
        comment: Comment.ID,
        content: String
    ) async throws -> String {
        try await client
            .put("/comment/\(comment)")
            .body(content)
            .send()
    }

    public func set(
        post: Post.ID,
        description: String
    ) async throws -> Modification<String?> {
        try await client
            .put("/post/\(post)/description")
            .body(description)
            .send()
    }

    public func set(
        post: Post.ID,
        title: String
    ) async throws -> Modification<String?> {
        try await client
            .put("/post/\(post)/title")
            .body(title)
            .send()
    }

    public func set(tag: Tag.ID, description: String) async throws -> String? {
        try await client
            .put("/tag/\(tag)/description")
            .body(description)
            .send()
    }

    public func set(tag: Tag.ID, name: String) async throws -> TagName {
        try await client
            .put("/tag/\(tag)/name/\(name)")
            .query(name: "main", value: true)
            .send()
    }
}
