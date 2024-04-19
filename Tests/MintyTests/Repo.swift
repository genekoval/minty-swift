import XCTest
@testable import Minty

private let serverEnv = "MINTY_TEST_URL"

private func getEnv(_ name: String) -> String {
    guard let value = ProcessInfo.processInfo.environment[name] else {
        fatalError("Undefined environment variable '\(name)'")
    }

    return value
}

private func getURL(_ envVar: String) -> URL {
    let string = getEnv(envVar)

    guard let url = URL(string: string) else {
        fatalError("\(envVar) value is an invalid URL: \(string)")
    }

    return url
}

private func getClient(_ envVar: String) -> MintyRepo {
    let url = getURL(envVar)

    guard let client = HTTPClient(baseURL: url) else {
        fatalError("Failed to build HTTP client from URL: \(url)")
    }

    return client
}

let repo = getClient(serverEnv)
