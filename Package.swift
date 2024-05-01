// swift-tools-version:5.10

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
            url: "https://git.aurora.aur/genya/swift-http",
            exact: "0.1.0"
        )
    ],
    targets: [
        .target(
            name: "Minty",
            dependencies: [
                .product(name: "SwiftHTTP", package: "swift-http")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "MintyTests",
            dependencies: ["Minty"]
        ),
    ]
)
