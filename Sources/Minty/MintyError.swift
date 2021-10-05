import Zipline

public enum MintyError: ZiplineError {
    case unspecified(message: String)

    public init(code: StatusType, decoder: ZiplineDecoder) throws {
        switch code {
        case 0:
            self = .unspecified(message: try String(from: decoder))
        default:
            self = .unspecified(message: "Unknown error code: \(code)")
        }
    }
}
