// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "Minty",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Minty",
            targets: ["Minty"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://git.aurora.aur/genya/fstore-swift",
            branch: "main"
        ),
        .package(
            url: "https://git.aurora.aur/genya/swift-http",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "Minty",
            dependencies: [
                .product(name: "Fstore", package: "fstore-swift"),
                .product(name: "SwiftHTTP", package: "swift-http")
            ]
        ),
        .testTarget(
            name: "MintyTests",
            dependencies: ["Minty"]
        ),
    ]
)
