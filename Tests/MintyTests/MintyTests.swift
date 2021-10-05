import XCTest
@testable import Minty

final class MintyTests: XCTestCase {
    func testConnection() throws {
        let repo: MintyRepo = try ZiplineClient(host: "nova.aur", port: 5077)
        let info = try repo.getServerInfo()

        XCTAssertFalse(info.version.isEmpty)
    }
}
