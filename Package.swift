// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "XCResultIssues",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "xcresult-issues", targets: ["xcresult-issues"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.2.1")),
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMinor(from: "5.0.3")),
    ],
    targets: [
        .executableTarget(
            name: "xcresult-issues",
            dependencies: [
                "XcresultIssues",
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-warn-concurrency", "-Xfrontend", "-enable-actor-data-race-checks"])
            ]
        ),
        .testTarget(
            name: "XcresultIssuesTests",
            dependencies: [
                "XcresultIssues",
            ]
        ),
        .target(
            name: "XcresultIssues",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
