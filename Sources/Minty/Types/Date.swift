import Foundation
import Zipline

private let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()

    formatter.formatOptions = [
        .withFractionalSeconds,
        .withInternetDateTime,
        .withSpaceBetweenDateAndTime
    ]

    return formatter
}()

extension Date: ZiplineCodable {
    public static func decode(
        from decoder: ZiplineDecoder
    ) async throws -> Date {
        let string = try await String.decode(from: decoder)

        guard let date = dateFormatter.date(from: string) else {
            throw ZiplineCoderError.badConversion(
                message: "Failed to parse date: \(string)"
            )
        }

        return date
    }

    public func encode(to encoder: ZiplineEncoder) async throws {
        try await dateFormatter.string(from: self).encode(to: encoder)
    }
}
