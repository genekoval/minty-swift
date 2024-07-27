import CryptoKit
import XCTest

final class ObjectTests: MintyTests {
    func testDownload() async throws {
        let url = try await repo.download(object: Objects.sand)
        let data = try Data(contentsOf: url)
        let digest = SHA256.hash(data: data)
        let hash = digest.compactMap { String(format: "%02x", $0) }.joined()

        XCTAssertEqual(
            "1231a42cd48638c8cf80eff03ee9a3da91ff4a3d7136d8883a35f329c7a2e7c0",
            hash
        )
    }

    func testGetObject() async throws {
        let id = Objects.bunny
        let object = try await repo.getObject(id: id)

        XCTAssertEqual(id, object.id)
        XCTAssertEqual(
            "7df68aa61121297801587e0318de4eccd30bb96c3a198b45abcc6cffb0cda0f1",
            object.hash
        )
        XCTAssertEqual(673_223_862, object.size)
        XCTAssertEqual("video", object.type)
        XCTAssertEqual("mp4", object.subtype)

        XCTAssert(object.posts.map(\.id).contains(Posts.bunny))
    }
}
