import Foundation
import Zipline

public struct DataWriter {
    private weak var encoder: ZiplineEncoder?

    fileprivate init(encoder: ZiplineEncoder) {
        self.encoder = encoder
    }

    public func write(data: Data) async throws {
        guard let encoder = encoder else { return }
        try await encoder.write(data: data)
    }
}

struct ObjectUpload: ZiplineEncodable {
    typealias Writer = (DataWriter) async throws -> Void

    let size: Int
    let writer: Writer

    public func encode(to encoder: ZiplineEncoder) async throws {
        try await encodeSize(size: size, to: encoder)
        try await writer(DataWriter(encoder: encoder))
    }
}
