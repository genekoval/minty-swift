import XCTest
@testable import Minty

private let url = URL(string: "https://example.com/hello")!

final class UserTests: MintyTests {
    private var user: TestUser!

    override func setUp() async throws {
        try await super.setUp()

        user = try await TestRepo.nextUser()
    }

    override func tearDown() async throws {
        try await user.repo.deleteUser()
    }

    func testAddAlias() async throws {
        let alias = "Alias"
        let names = try await user.repo.addUserAlias(alias)

        XCTAssertEqual(user.name, names.name)
        XCTAssertEqual([alias], names.aliases)
    }

    func testAddSource() async throws {
        let source = try await user.repo.addUserSource(url)

        XCTAssertEqual(url, source.url)
        XCTAssertNil(source.icon)

        let user = try await user.repo.getAuthenticatedUser()

        XCTAssertEqual([source], user.profile.sources)
    }

    func testDeleteAlias() async throws {
        let alias = "Alias"
        var names = try await user.repo.addUserAlias(alias)

        XCTAssertEqual([alias], names.aliases)

        names = try await user.repo.deleteUserAlias(alias)

        XCTAssertEqual(user.name, names.name)
        XCTAssert(names.aliases.isEmpty)
    }

    func testDeleteSource() async throws {
        let source = try await user.repo.addUserSource(url)
        try await user.repo.deleteUserSource(id: source.id)

        let user = try await user.repo.getAuthenticatedUser()
        XCTAssert(user.profile.sources.isEmpty)
    }

    func testGetUser() async throws {
        let id = Users.minty
        let user = try await user.repo.getUser(id: id)

        XCTAssertEqual(id, user.id)
        XCTAssertEqual("minty@example.com", user.email)
        XCTAssertEqual("minty", user.profile.name)
        XCTAssert(user.admin)
    }

    func testGetUsers() async throws {
        let query = ProfileQuery(size: 10_000, name: "minty")
        let result = try await user.repo.getUsers(query: query)
        XCTAssert(result.total >= 2)

        let user = try await user.repo.getAuthenticatedUser()
        let hits = result.hits.map(\.id)

        XCTAssert(hits.contains(user.id))
        XCTAssert(hits.contains(Users.minty))
    }

    func testSetDescription() async throws {
        let description = "A description of a user."
        let result = try await user.repo.setUserDescription(description)

        XCTAssertEqual(description, result)
    }

    func testSetEmail() async throws {
        let email = "new@example.com"

        try await user.repo.setUserEmail(email)

        let user = try await user.repo.getAuthenticatedUser()

        XCTAssertEqual(email, user.email)
    }

    func testSetName() async throws {
        let name = "New Name"
        let names = try await user.repo.setUserName(name)

        XCTAssertEqual(name, names.name)
        XCTAssert(names.aliases.isEmpty)
    }

    func testSetPassword() async throws {
        let password = "my.super.secret.password"

        try await user.repo.setUserPassword(password)
        try await user.repo.signOut(keepingPassword: false)

        let email = "\(user.name)@example.com"
        let login = Login(email: email, password: password)
        _ = try await user.repo.authenticate(login)

        let user = try await user.repo.getAuthenticatedUser()
        XCTAssertEqual(email, user.email)
    }
}
