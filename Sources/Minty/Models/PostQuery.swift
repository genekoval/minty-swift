import Foundation

public struct PostQuery {
    public struct Sort {
        public enum SortValue: String {
            case dateCreated = "created"
            case dateModified = "modified"
            case relevance = "relevance"
            case title = "title"
        }

        public static let created = Sort(
            order: .descending,
            value: .dateCreated
        )
        public static let modified = Sort(
            order: .descending,
            value: .dateModified
        )
        public static let relevance = Sort(
            order: .descending,
            value: .relevance
        )
        public static let title = Sort(
            order: .ascending,
            value: .title
        )

        public var order: SortOrder
        public var value: SortValue

        public init(order: SortOrder, value: SortValue) {
            self.order = order
            self.value = value
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
