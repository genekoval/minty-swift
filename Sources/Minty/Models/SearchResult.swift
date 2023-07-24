public struct SearchResult<T: Codable>: Codable {
    public var hits: [T]
    public var total: Int
}
