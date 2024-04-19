import XCTest
@testable import Minty

private let url = URL(string: "https://example.com/hello")!

final class TagTests: XCTestCase {
    func testAddTag() async throws {
        let name = "Minty Test"
        let id = try await repo.addTag(name: name)
        let tag = try await repo.getTag(id: id)

        XCTAssertEqual(id, tag.id)
        XCTAssertEqual(name, tag.name)
    }

    func testAddTagAlias() async throws {
        let name = "Name"
        let alias = "Alias"

        let id = try await repo.addTag(name: name)
        let names = try await repo.addTagAlias(tag: id, alias: alias)

        XCTAssertEqual(name, names.name)
        XCTAssertEqual([alias], names.aliases)
    }

    func testAddTagSource() async throws {
        let id = try await repo.addTag(name: "Tag Name")
        let source = try await repo.addTagSource(tag: id, url: url)

        XCTAssertEqual(url, source.url)
        XCTAssertNil(source.icon)

        let tag = try await repo.getTag(id: id)

        XCTAssertEqual([source], tag.sources)
    }

    func testDeleteTag() async throws {
        let tag = try await repo.addTag(name: "Delete Me")
        try await repo.deleteTag(id: tag)

        do {
            _ = try await repo.getTag(id: tag)
            XCTFail("tag should not exist")
        }
        catch MintyError.notFound(let entity, let id) {
            XCTAssertEqual("tag", entity)
            XCTAssertEqual(tag, id)
        }
    }

    func testDeleteTagAlias() async throws {
        let name = "Minty Tag"
        let alias = "Alias"
        let id = try await repo.addTag(name: name)
        var names = try await repo.addTagAlias(tag: id, alias: alias)

        XCTAssertEqual([alias], names.aliases)

        names = try await repo.deleteTagAlias(id: id, alias: alias)

        XCTAssertEqual(name, names.name)
        XCTAssert(names.aliases.isEmpty)
    }

    func testDeleteTagSource() async throws {
        let id = try await repo.addTag(name: "Minty Tag")
        let source = try await repo.addTagSource(tag: id, url: url)

        try await repo.deleteTagSource(id: id, source: source.id)

        let tag = try await repo.getTag(id: id)

        XCTAssert(tag.sources.isEmpty)
    }

    func testGetTags() async throws {
        let name = "Swift"
        let id = try await repo.addTag(name: name)

        let query = TagQuery(size: 10_000, name: "s")
        let result = try await repo.getTags(query: query)
        XCTAssert(result.total >= 1)

        let hit = result.hits.first(where: { $0.id == id })
        XCTAssertNotNil(hit)

        let tag = hit!
        XCTAssertEqual(id, tag.id)
        XCTAssertEqual(name, tag.name)
    }

    func testSetTagDescription() async throws {
        let id = try await repo.addTag(name: "Tag Name")
        let description = "A description of a tag."
        let result = try await repo.setTagDescription(
            id: id,
            description: description
        )

        XCTAssertEqual(description, result)
    }

    func testSetTagName() async throws {
        let id = try await repo.addTag(name: "Original Name")
        let name = "New Name"
        let names = try await repo.setTagName(id: id, name: name)

        XCTAssertEqual(name, names.name)
        XCTAssert(names.aliases.isEmpty)
    }
}
