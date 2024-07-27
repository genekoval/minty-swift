import XCTest
@testable import Minty

final class PostTests: MintyTests {
    private func createPost() async throws -> Post.ID {
        try await repo.createPost(parts: PostParts())
    }

    private func find(
        query: consuming PostQuery,
        expect expected: [UUID]
    ) async throws {
        query.tags.append(Tags.languages)

        let result = try await repo.getPosts(query: query)
        XCTAssertEqual(expected.count, result.hits.count)

        let hits = result.hits.map(\.id)
        XCTAssertEqual(expected, hits)
    }

    private func findText(_ text: String, expect expected: [UUID]) async throws {
        try await find(
            query: .init(size: 10_000, text: text, sort: .title),
            expect: expected
        )
    }

    func testAddPostTag() async throws {
        let post = try await createPost()
        let tag = Tags.videos

        try await repo.addPostTag(post: post, tag: tag)

        let tags = try await repo.getPost(id: post).tags
        XCTAssertEqual(1, tags.count)
        XCTAssertEqual(tag, tags.first?.id)
    }

    func testAddRelatedPost() async throws {
        let post = try await createPost()
        let related = Posts.bunny

        try await repo.addRelatedPost(post: post, related: related)

        let posts = try await repo.getPost(id: post).posts
        XCTAssertEqual(1, posts.count)
        XCTAssertEqual(related, posts.first?.id)
    }

    func testAppendPostObjects() async throws {
        let id = try await repo.createPost(parts: PostParts(
            objects: [Objects.sand]
        ))
        let post = try await repo.getPost(id: id)
        let modified = try await repo.appendPostObjects(
            post: id,
            objects: [Objects.bunny]
        )
        XCTAssert(modified > post.modified)

        let objects = try await repo.getPost(id: id).objects.map(\.id)
        XCTAssertEqual([Objects.sand, Objects.bunny], objects)
    }

    func testCreatePost() async throws {
        let parts = PostParts(
            title: "My Test Post",
            description: "A test description.",
            objects: [Objects.bunny],
            posts: [Posts.bunny],
            tags: [Tags.videos]
        )

        let id = try await repo.createPost(parts: parts)
        let post = try await repo.getPost(id: id)

        XCTAssertEqual(id, post.id)
        XCTAssertEqual(parts.title, post.title)
        XCTAssertEqual(parts.description, post.description)
        XCTAssertEqual(parts.objects, post.objects.map(\.id))
        XCTAssertEqual(parts.posts, post.posts.map(\.id))
        XCTAssertEqual(parts.tags, post.tags.map(\.id))
        XCTAssertEqual(Visibility.pub, post.visibility)
        XCTAssertEqual(0, post.commentCount)
        XCTAssertEqual(post.created, post.modified)
    }

    func testDeletePost() async throws {
        let post = try await repo.createPost(parts: PostParts(title: "Delete Me"))

        try await repo.deletePost(id: post)

        do {
            _ = try await repo.getPost(id: post)
            XCTFail("post should not exist")
        }
        catch MintyError.notFound(let entity, let id) {
            XCTAssertEqual("post", entity)
            XCTAssertEqual(post, id)
        }
    }

    func testDeletePostObjects() async throws {
        let objects = [Objects.sand, Objects.bunny]
        let id = try await repo.createPost(parts: PostParts(objects: objects))
        let post = try await repo.getPost(id: id)
        let modified = try await repo.deletePostObjects(
            id: id,
            objects: objects
        )
        XCTAssert(modified > post.modified)

        let result = try await repo.getPost(id: id).objects
        XCTAssert(result.isEmpty)
    }

    func testDeletePostTag() async throws {
        let tag = Tags.videos
        let id = try await repo.createPost(parts: PostParts(tags: [tag]))

        try await repo.deletePostTag(id: id, tag: tag)

        let tags = try await repo.getPost(id: id).tags
        XCTAssert(tags.isEmpty)
    }

    func testDeleteRelatedPost() async throws {
        let related = Posts.bunny
        let id = try await repo.createPost(parts: PostParts(posts: [related]))

        try await repo.deleteRelatedPost(id: id, related: related)

        let posts = try await repo.getPost(id: id).posts
        XCTAssert(posts.isEmpty)
    }

    func testGetPosts() async throws {
        // Limit results
        try await find(
            query: .init(size: 3, sort: .title),
            expect: [Posts.c, Posts.cpp, Posts.java]
        )

        // Search title
        try await findText("java", expect: [Posts.java])
        try await findText("c", expect: [Posts.c, Posts.cpp])

        // Search description
        try await findText(
            "programming language",
            expect: [Posts.c, Posts.cpp, Posts.java, Posts.js]
        )
        try await findText("html", expect: [Posts.js])

        // Sort order
        try await find(
            query: .init(
                size: 10_000,
                sort: .init(by: .title, order: .descending)
            ),
            expect: [Posts.rust, Posts.js, Posts.java, Posts.cpp, Posts.c]
        )
    }

    func testInsertPostObjects() async throws {
        let id = try await repo.createPost(parts: PostParts(
            objects: [Objects.bunny]
        ))
        let post = try await repo.getPost(id: id)
        let modified = try await repo.insertPostObjects(
            id: id,
            objects: [Objects.sand],
            before: Objects.bunny
        )
        XCTAssert(modified > post.modified)

        let objects = try await repo.getPost(id: id).objects.map(\.id)
        XCTAssertEqual([Objects.sand, Objects.bunny], objects)
    }

    func testPublishPost() async throws {
        let id = try await repo.createPost(parts: PostParts(
            title: "Publishing a Draft",
            visibility: .draft
        ))

        try await repo.publishPost(id: id)

        let post = try await repo.getPost(id: id)

        XCTAssertEqual(Visibility.pub, post.visibility)
    }

    func testSetPostDescription() async throws {
        let description = "Test description"
        let id = try await createPost()
        let update = try await repo.setPostDescription(
            id: id,
            description: description
        )
        let post = try await repo.getPost(id: id)

        XCTAssertEqual(description, update.newValue)
        XCTAssertEqual(post.modified, update.dateModified)
    }

    func testSetPostTitle() async throws {
        let title = "Test Title"
        let id = try await createPost()
        let update = try await repo.setPostTitle(id: id, title: title)
        let post = try await repo.getPost(id: id)

        XCTAssertEqual(title, update.newValue)
        XCTAssertEqual(post.modified, update.dateModified)
    }
}
