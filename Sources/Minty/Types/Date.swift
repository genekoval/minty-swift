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
    public init(from decoder: ZiplineDecoder) throws {
        let string = try String(from: decoder)

        guard let date = dateFormatter.date(from: string) else {
            throw ZiplineCoderError.badConversion(
                message: "Failed to parse date: \(string)"
            )
        }

        self = date
    }

    public func encode(to encoder: ZiplineEncoder) {
        dateFormatter.string(from: self).encode(to: encoder)
    }
}
