import XCTest
@testable import Minty

final class MintyTests: XCTestCase {
    func testConnection() async throws {
        let (_, metadata) = try await ZiplineClient.create(
            host: "nova.aur",
            port: 5077
        )

        XCTAssertFalse(metadata.version.isEmpty)
    }
}
