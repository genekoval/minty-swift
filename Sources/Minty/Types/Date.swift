import Foundation
import Zipline

let formatter = DateFormatter()

extension Date: ZiplineCodable {
    public init(from decoder: ZiplineDecoder) throws {
        let string = try String(from: decoder)

        guard let date = formatter.date(from: string) else {
            throw ZiplineCoderError.badConversion(
                message: "Failed to parse date: \(string)"
            )
        }

        self = date
    }

    public func encode(to encoder: ZiplineEncoder) {
        formatter.string(from: self).encode(to: encoder)
    }
}
