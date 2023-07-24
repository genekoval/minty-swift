import Foundation

public struct Modification<T: Codable>: Codable {
    public var modified: Date
    public var value: T
}
