import Foundation

public struct ObjectPreview: Codable, Hashable, Identifiable {
    public var id: UUID
    public var previewId: UUID?
    public var type: String
    public var subtype: String
}
