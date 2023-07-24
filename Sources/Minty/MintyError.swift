public enum MintyError: Error {
    case unspecified(message: String)
    case internalError
    case invalidData(message: String)
    case notFound(message: String)
    case downloadError(url: String, status: Int64, data: ObjectPreview)
}
