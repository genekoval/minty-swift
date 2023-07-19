import XCTest
@testable import Minty

final class MintyTests: XCTestCase {
    func testConnection() async throws {
        let client = try await ZiplineClient(
            host: "nova.aur",
            port: 5077
        )

        XCTAssertFalse(client.metadata.version.isEmpty)
    }
}
