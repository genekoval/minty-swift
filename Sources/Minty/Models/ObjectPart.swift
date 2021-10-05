import Foundation
import Zipline

public struct DataWriter {
    private let encoder: ZiplineEncoder

    fileprivate init(encoder: ZiplineEncoder) {
        self.encoder = encoder
    }

    public func write(data: Data) {
        encoder.write(src: (data as NSData).bytes, count: data.count)
    }
}

public struct ObjectPart: ZiplineEncodable {
    private let src: (DataWriter) -> Void
    private let totalBytes: Int

    init(count: Int, src: @escaping (DataWriter) -> Void) {
        self.src = src
        totalBytes = count
    }

    public func encode(to encoder: ZiplineEncoder) {
        encodeSize(size: totalBytes, to: encoder)

        let writer = DataWriter(encoder: encoder)
        src(writer)
    }
}
