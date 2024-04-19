import XCTest
@testable import Minty

final class CommentTests: XCTestCase {
    func testAddComment() async throws {
        let content = "A new comment!"

        let comment = try await repo.addComment(
            post: Posts.bunny,
            content: content
        )

        XCTAssertEqual(content, comment.content)
        XCTAssertEqual(0, comment.level)
    }

    func testDeleteComment() async throws {
        let first = try await repo.addComment(
            post: Posts.bunny,
            content: "First"
        ).id

        _ = try await repo.reply(
            to: first,
            content: "Second"
        ).id

        try await repo.deleteComment(id: first, recursive: false)
        let comment = try await repo.getComment(id: first)
        XCTAssert(comment.content.isEmpty)

        try await repo.deleteComment(id: first, recursive: true)

        do {
            _ = try await repo.getComment(id: first)
            XCTFail("comment should not exist")
        } catch MintyError.notFound(let entity, let id) {
            XCTAssertEqual("comment", entity)
            XCTAssertEqual(first, id)
        } catch {
            throw error
        }
    }

    func testGetComment() async throws {
        let comment = try await repo.getComment(id: Comments.world)

        XCTAssertEqual(Comments.world, comment.id)
        XCTAssertEqual(Posts.comments, comment.postId)
        XCTAssertNil(comment.parentId)
        XCTAssertEqual(0, comment.level)
        XCTAssertEqual("Hello, World!", comment.content)
    }

    func testGetComments() async throws {
        let comments = try await repo.getComments(for: Posts.comments)

        XCTAssertEqual(7, comments.count)
    }

    func testSetCommentContent() async throws {
        let original = "My original comment."
        let edit = "My edit."

        let id = try await repo.addComment(
            post: Posts.bunny,
            content: original
        ).id

        let content = try await repo.setCommentContent(id: id, content: edit)

        XCTAssertEqual(edit, content)
    }
}
