import Foundation

public struct TagQuery: Hashable {
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
