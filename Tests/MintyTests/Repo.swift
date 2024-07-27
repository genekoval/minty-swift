import XCTest
@testable import Minty

private func getEnv(_ name: String) -> String {
    guard let value = ProcessInfo.processInfo.environment[name] else {
        fatalError("Undefined environment variable '\(name)'")
    }

    return value
}

private func getURL(fromEnv envVar: String) -> URL {
    let string = getEnv(envVar)

    guard let url = URL(string: string) else {
        fatalError("\(envVar) value is an invalid URL: \(string)")
    }

    return url
}

struct TestUser {
    var name: String
    var repo: MintyRepo
}

actor TestRepo {
    private static let url = getURL(fromEnv: "MINTY_TEST_URL")

    private static var userCounter = 0
    private static var repo: MintyRepo?

    static func admin() async throws -> MintyRepo {
        if let repo {
            return repo
        }

        let repo = build()
        let login = Login(email: "minty@example.com", password: "password")
        _ = try await repo.authenticate(login)

        self.repo = repo
        return repo
    }

    static func build() -> MintyRepo {
        let session = URLSession(configuration: .ephemeral)

        guard let client = HTTPClient(
            baseURL: url,
            session: session,
            credentialPersistence: .forSession
        ) else {
            fatalError("Failed to build HTTP client from URL: \(url)")
        }

        return client
    }

    static func newUser(name: String) async throws -> MintyRepo {
        let email = "\(name)@example.com"
        let password = "\(name) password"

        let info = SignUp(username: name, email: email, password: password)
        let repo = build()

        do {
            _ = try await repo.signUp(info, invitation: nil)
        } catch MintyError.alreadyExists(_) {
            let info = Login(email: email, password: password)
            _ = try await repo.authenticate(info)
        }

        return repo
    }

    static func nextUser() async throws -> TestUser {
        let i = userCounter
        userCounter += 1

        let name = "minty-swift\(i)"
        let repo = try await newUser(name: name)

        return .init(name: name, repo: repo)
    }
}

class MintyTests: XCTestCase {
    var repo: MintyRepo!

    override func setUp() async throws {
        try await super.setUp()

        repo = try await TestRepo.admin()
    }
}
