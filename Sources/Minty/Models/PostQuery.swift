import Foundation

public struct PostQuery {
    public struct Sort: Hashable {
        public enum SortValue: String, Identifiable, CaseIterable {
            case dateCreated = "created"
            case dateModified = "modified"
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

        public static let created = Sort(by: .dateCreated)
        public static let modified = Sort(by: .dateModified)
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
    public var text: String?
    public var tags: [UUID]
    public var visibility: Visibility
    public var sort: Sort

    public init(
        from: Int = 0,
        size: Int,
        text: String? = nil,
        tags: [UUID] = [],
        visibility: Visibility = .pub,
        sort: Sort = .created
    ) {
        self.from = from
        self.size = size
        self.text = text
        self.tags = tags
        self.visibility = visibility
        self.sort = sort
    }
}
