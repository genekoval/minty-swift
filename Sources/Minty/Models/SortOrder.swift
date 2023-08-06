public enum SortOrder: String {
    case ascending = "asc"
    case descending = "desc"

    public mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}
