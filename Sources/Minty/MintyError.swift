import Zipline

public enum MintyError: ZiplineError {
    public static func decode(
        from decoder: ZiplineDecoder,
        code: StatusType
    ) async throws -> MintyError {
        switch code {
        case 0:
            return .unspecified(message: try await String.decode(from: decoder))
        default:
            return .unspecified(message: "unknown error code: \(code)")
        }
    }

    case unspecified(message: String)
}
