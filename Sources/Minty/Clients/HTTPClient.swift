import Foundation
import Fstore

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

public final class HTTPClient: MintyRepo {
    private let baseURL: URL
    private let bucket: UUID
    private let objectStore: ObjectStore
    private let session: URLSession
    private let decoder: JSONDecoder

    public let version: String

    public init(baseURL: URL, session: URLSession = .shared) async throws {
        self.baseURL = baseURL
        self.session = session

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        let (data, response) = try await session.data(from: baseURL)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        let info = try decoder.decode(ServerInfo.self, from: data)
        self.version = info.version
        self.bucket = info.objectSource.bucketId

        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = info.objectSource.host ?? baseURL.host
        components.port = info.objectSource.port

        objectStore = Fstore.HTTPClient(baseURL: components.url!)
    }

    public func addComment(
        post: UUID,
        content: String
    ) async throws -> Comment {
        var url = baseURL.appending(path: "comments")
        url.append(path: post.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(content.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Comment.self, from: data)
    }

    public func addObject(file: URL) async throws -> ObjectPreview {
        let url = baseURL.appending(path: "object")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await session.upload(
            for: request,
            fromFile: file
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(ObjectPreview.self, from: data)
    }

    public func addObjects(url: String) async throws -> [ObjectPreview] {
        var requestURL = baseURL.appending(path: "object")
        requestURL.append(path: "url")

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(url.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode([ObjectPreview].self, from: data)
    }

    public func add(post: UUID, objects: [UUID]) async throws -> Date {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "objects")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = objects.map { $0.uuidString }.joined(separator: "\n")

        let (data, response) = try await session.upload(
            for: request,
            from: Data(body.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Date.self, from: data)
    }

    public func addPostTag(post: UUID, tag: UUID) async throws {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "tag")
        url.append(path: tag.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func addRelatedPost(post: UUID, related: UUID) async throws {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "related")
        url.append(path: related.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func addTag(name: String) async throws -> UUID {
        var url = baseURL.appending(path: "tag")
        url.append(path: name)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(UUID.self, from: data)
    }

    public func addTagAlias(tag: UUID, alias: String) async throws -> TagName {
        var url = baseURL.appending(path: "tag")
        url.append(path: tag.uuidString)
        url.append(path: "name")
        url.append(path: alias)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(TagName.self, from: data)
    }

    public func addTagSource(tag: UUID, url: String) async throws -> Source {
        var requestURL = baseURL.appending(path: "tag")
        requestURL.append(path: tag.uuidString)
        requestURL.append(path: "source")

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(url.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Source.self, from: data)
    }

    public func createPost(draft: UUID) async throws {
        var url = baseURL.appending(path: "post")
        url.append(path: draft.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func createPostDraft() async throws -> UUID {
        let url = baseURL.appending(path: "post")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(UUID.self, from: data)
    }

    public func delete(post: UUID) async throws {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func delete(post: UUID, objects: [UUID]) async throws -> Date {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "objects")

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let body = objects.map { $0.uuidString }.joined(separator: "\n")

        let (data, response) = try await session.upload(
            for: request,
            from: Data(body.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Date.self, from: data)
    }

    public func delete(post: UUID, tag: UUID) async throws {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "tag")
        url.append(path: tag.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func delete(post: UUID, related: UUID) async throws {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "related")
        url.append(path: related.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func delete(tag: UUID) async throws {
        var url = baseURL.appending(path: "tag")
        url.append(path: tag.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func delete(tag: UUID, alias: String) async throws -> TagName {
        var url = baseURL.appending(path: "tag")
        url.append(path: tag.uuidString)
        url.append(path: "name")
        url.append(path: alias)

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(TagName.self, from: data)
    }

    public func delete(tag: UUID, source: Int64) async throws {
        var url = baseURL.appending(path: "tag")
        url.append(path: tag.uuidString)
        url.append(path: "source")
        url.append(path: String(source))

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }
    }

    public func download(object: UUID) async throws -> URL {
        try await objectStore.downloadObject(bucket: bucket, object: object)
    }

    public func download(object: UUID, destination: URL) async throws {
        try await objectStore.downloadObject(
            bucket: bucket,
            object: object,
            destination: destination
        )
    }

    public func get(comment: UUID) async throws -> CommentDetail {
        var url = baseURL.appending(path: "comment")
        url.append(path: comment.uuidString)

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(CommentDetail.self, from: data)
    }

    public func getComments(for post: UUID) async throws -> [Comment] {
        var url = baseURL.appending(path: "comments")
        url.append(path: post.uuidString)

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode([Comment].self, from: data)
    }

    public func get(object: UUID) async throws -> Object {
        var url = baseURL.appending(path: "object")
        url.append(path: object.uuidString)

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Object.self, from: data)
    }

    public func get(post: UUID) async throws -> Post {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Post.self, from: data)
    }

    public func getPosts(
        query: PostQuery
    ) async throws -> SearchResult<PostPreview> {
        var url = baseURL.appending(path: "posts")
        url.append(queryItems: [
            .init(name: "from", value: String(query.from)),
            .init(name: "size", value: String(query.size)),
            .init(name: "q", value: query.text),
            .init(
                name: "tags",
                value: query.tags.map { $0.uuidString }.joined(separator: ",")
            ),
            .init(name: "vis", value: query.visibility.description),
            .init(name: "sort", value: query.sort.value.rawValue),
            .init(name: "order", value: query.sort.order.rawValue)
        ])

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MintyError.internalError
        }

        guard httpResponse.statusCode == 200 else {
            let message = String(decoding: data, as: UTF8.self)

            switch httpResponse.statusCode {
            case 400: throw MintyError.invalidData(message: message)
            default: throw MintyError.unspecified(message: message)
            }
        }

        do {
            return try decoder.decode(
                SearchResult<PostPreview>.self,
                from: data
            )
        }
        catch DecodingError.keyNotFound(let key, let context) {
            print("\(key): \(context.debugDescription)")
        }
        catch DecodingError.typeMismatch(_, let context) {
            print("Type mismatch for key \(context.codingPath.last!.stringValue): \(context.debugDescription)")
        }
        catch {
            print(error)
        }

        throw MintyError.internalError
    }

    public func getServerInfo() async throws -> ServerInfo {
        let (data, response) = try await session.data(from: baseURL)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(ServerInfo.self, from: data)
    }

    public func get(tag: UUID) async throws -> Tag {
        var url = baseURL.appending(path: "tag")
        url.append(path: tag.uuidString)

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Tag.self, from: data)
    }

    public func getTags(query: TagQuery) async throws -> SearchResult<TagPreview> {
        var url = baseURL.appending(path: "tags")
        url.append(queryItems: [
            .init(name: "from", value: String(query.from)),
            .init(name: "size", value: String(query.size)),
            .init(name: "name", value: query.name),
            .init(
                name: "exclude",
                value: query.exclude.map {
                    $0.uuidString
                }.joined(separator: ",")
            )
        ])

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(
            SearchResult<TagPreview>.self,
            from: data
        )
    }

    public func insert(
        post: UUID,
        objects: [UUID],
        before destination: UUID
    ) async throws -> Date {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "objects")
        url.append(path: destination.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = objects.map { $0.uuidString }.joined(separator: "\n")

        let (data, response) = try await session.upload(
            for: request,
            from: Data(body.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Date.self, from: data)
    }

    public func reply(
        to parent: UUID,
        content: String
    ) async throws -> Comment {
        var url = baseURL.appending(path: "comment")
        url.append(path: parent.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(content.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Comment.self, from: data)
    }

    public func set(comment: UUID, content: String) async throws -> String {
        var url = baseURL.appending(path: "comment")
        url.append(path: comment.uuidString)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(content.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(String.self, from: data)
    }

    public func set(
        post: UUID,
        description: String
    ) async throws -> Modification<String?> {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "description")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(description.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Modification<String?>.self, from: data)
    }

    public func set(
        post: UUID,
        title: String
    ) async throws -> Modification<String?> {
        var url = baseURL.appending(path: "post")
        url.append(path: post.uuidString)
        url.append(path: "title")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(title.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(Modification<String?>.self, from: data)
    }

    public func set(tag: UUID, description: String) async throws -> String? {
        var url = baseURL.appending(path: "tag")
        url.append(path: tag.uuidString)
        url.append(path: "description")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (data, response) = try await session.upload(
            for: request,
            from: Data(description.utf8)
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(String?.self, from: data)
    }

    public func set(tag: UUID, name: String) async throws -> TagName {
        var url = baseURL.appending(path: "tag")
        url.append(path: tag.uuidString)
        url.append(path: "name")
        url.append(path: name)
        url.append(queryItems: [.init(name: "main", value: "t")])

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MintyError.internalError
        }

        return try decoder.decode(TagName.self, from: data)
    }
}
