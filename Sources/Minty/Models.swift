import Foundation

public struct About: Codable {
    public var version: String
}

public struct Comment: Codable, Hashable, Identifiable {
    public var id: UUID
    public var user: UserPreview?
    public var postId: UUID
    public var parentId: UUID?
    public var level: Int
    public var content: String
    public var created: Date
}

public struct CommentData: Codable, Hashable, Identifiable {
    public var id: UUID
    public var user: UserPreview?
    public var content: String
    public var level: Int
    public var created: Date
}

public struct EntityProfile: Codable, Hashable {
    public var name: String
    public var aliases: [String]
    public var description: String
    public var sources: [Source]
    public var avatar: UUID?
    public var banner: UUID?
    public var created: Date
}

public struct Login: Codable {
    public var email: String
    public var password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct Modification<T: Codable>: Codable {
    public var dateModified: Date
    public var newValue: T
}

public struct Object: Codable, Hashable, Identifiable {
    public var id: UUID
    public var hash: String
    public var size: Int64
    public var type: String
    public var subtype: String
    public var added: Date
    public var previewId: UUID?
    public var posts: [PostPreview]

    public var preview: ObjectPreview {
        ObjectPreview(
            id: id,
            previewId: previewId,
            type: type,
            subtype: subtype
        )
    }
}

public struct ObjectPreview: Codable, Hashable, Identifiable {
    public var id: UUID
    public var previewId: UUID?
    public var type: String
    public var subtype: String
}

public struct ObjectSummary: Codable {
    public var mediaType: String
    public var size: Int
}

public struct Post: Codable, Hashable, Identifiable {
    public var id: UUID
    public var poster: UserPreview?
    public var title: String
    public var description: String
    public var visibility: Visibility
    public var created: Date
    public var modified: Date
    public var objects: [ObjectPreview]
    public var posts: [PostPreview]
    public var tags: [TagPreview]
    public var commentCount: Int
}

public struct PostParts: Codable {
    public var title: String?
    public var description: String?
    public var visibility: Visibility?
    public var objects: [UUID]?
    public var posts: [UUID]?
    public var tags: [UUID]?

    public init(
        title: String? = nil,
        description: String? = nil,
        visibility: Visibility? = nil,
        objects: [UUID]? = nil,
        posts: [UUID]? = nil,
        tags: [UUID]? = nil
    ) {
        self.title = title
        self.description = description
        self.visibility = visibility
        self.objects = objects
        self.posts = posts
        self.tags = tags
    }
}

public struct PostPreview: Codable, Hashable, Identifiable {
    public var id: UUID
    public var poster: UserPreview?
    public var title: String
    public var preview: ObjectPreview?
    public var commentCount: Int
    public var objectCount: Int
    public var created: Date
}

public struct PostQuery {
    public struct Sort: Hashable {
        public enum SortValue: String, Identifiable, CaseIterable {
            case created = "created"
            case modified = "modified"
            case relevance = "relevance"
            case title = "title"

            public var defaultOrder: SortOrder {
                switch self {
                case .title: return .ascending
                default: return .descending
                }
            }

            public var id: Self { self }
        }

        public static let created = Sort(by: .created)
        public static let modified = Sort(by: .modified)
        public static let relevance = Sort(by: .relevance)
        public static let title = Sort(by: .title)

        public var order: SortOrder
        public var value: SortValue

        public init(by value: SortValue) {
            self.init(by: value, order: value.defaultOrder)
        }

        public init(by value: SortValue, order: SortOrder) {
            self.value = value
            self.order = order
        }
    }

    public var from: Int
    public var size: Int
    public var poster: UUID?
    public var text: String
    public var tags: [UUID]
    public var visibility: Visibility
    public var sort: Sort

    public init(
        from: Int = 0,
        size: Int,
        poster: UUID? = nil,
        text: String = "",
        tags: [UUID] = [],
        visibility: Visibility = .pub,
        sort: Sort = .created
    ) {
        self.from = from
        self.size = size
        self.poster = poster
        self.text = text
        self.tags = tags
        self.visibility = visibility
        self.sort = sort
    }
}

public struct ProfileName: Codable, Hashable {
    public var name: String
    public var aliases: [String]
}

public struct ProfileQuery: Hashable {
    public var from: Int
    public var size: Int
    public var name: String
    public var exclude: [UUID]

    public init(
        from: Int = 0,
        size: Int,
        name: String = "",
        exclude: [UUID] = []
    ) {
        self.from = from
        self.size = size
        self.name = name
        self.exclude = exclude
    }
}

public struct SearchResult<T: Codable>: Codable {
    public var hits: [T]
    public var total: Int
}

public struct SignUp: Codable {
    public var username: String
    public var email: String
    public var password: String

    public init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }
}

public enum SortOrder: String {
    case ascending = "asc"
    case descending = "desc"

    public mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

public struct Source: Codable, Hashable, Identifiable {
    public var id: Int64
    public var url: URL
    public var icon: UUID?
}

public struct Tag: Codable, Hashable, Identifiable {
    public var id: UUID
    public var profile: EntityProfile
    public var creator: UserPreview?
    public var postCount: Int
}

public struct TagPreview: Codable, Hashable, Identifiable {
    public var id: UUID
    public var name: String
    public var avatar: UUID?
}

public struct User: Codable, Hashable, Identifiable {
    public var id: UUID
    public var email: String
    public var admin: Bool
    public var profile: EntityProfile
    public var postCount: Int
    public var commentCount: Int
    public var tagCount: Int
}

public struct UserPreview: Codable, Hashable, Identifiable {
    public var id: UUID
    public var name: String
    public var avatar: UUID?

    public init(id: UUID, name: String, avatar: UUID? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
    }
}

public enum Visibility: Int32, Codable, CustomStringConvertible {
    case invalid = -1
    case draft
    case pub

    public var description: String {
        switch self {
        case .invalid: return "invalid"
        case .draft: return "draft"
        case .pub: return "public"
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "draft":
            self = .draft
        case "public":
            self = .pub
        default:
            self = .invalid
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value: String?

        switch self {
        case .draft:
            value = "draft"
        case .pub:
            value = "public"
        default:
            value = nil
        }

        try container.encode(value)
    }
}
