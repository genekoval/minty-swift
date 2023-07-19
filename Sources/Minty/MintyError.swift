import Zipline

public enum MintyError: ZiplineError {
    public static func decode(
        from decoder: ZiplineDecoder,
        code: StatusType
    ) async throws -> MintyError {
        switch code {
        case 0:
            return .internalError
        case 1:
            return .invalidData(message: try await String.decode(from: decoder))
        case 2:
            return .notFound(message: try await String.decode(from: decoder))
        case 3:
            return .downloadError(
                url: try await String.decode(from: decoder),
                status: try await Int64.decode(from: decoder),
                data: try await ObjectPreview.decode(from: decoder)
            )
        default:
            return .unspecified(message: "Unknown error code: \(code)")
        }
    }

    case unspecified(message: String)
    case internalError
    case invalidData(message: String)
    case notFound(message: String)
    case downloadError(url: String, status: Int64, data: ObjectPreview)
}
