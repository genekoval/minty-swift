import Foundation
import Zipline

public struct ObjectPreview: Codable, Hashable, Identifiable, ZiplineObject {
    public var id: UUID = .empty
    public var previewId: UUID?
    public var type: String = ""
    public var subtype: String = ""

    public var coders: [Coder<Self>] {[
        Coder(\Self.id),
        Coder(\Self.previewId),
        Coder(\Self.type),
        Coder(\Self.subtype)
    ]}

    public init() { }
}
