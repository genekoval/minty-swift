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
