import Zipline

public enum Visibility: Int32, Codable, ZiplineCodable {
    public static func decode(
        from decoder: ZiplineDecoder
    ) async throws -> Visibility {
        let value = try await Int32.decode(from: decoder)

        guard let result = Visibility(rawValue: value) else {
            return .invalid
        }

        return result
    }

    case invalid = -1
    case draft
    case pub

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

    public func encode(to encoder: ZiplineEncoder) async throws {
        try await rawValue.encode(to: encoder)
    }
}
