// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftLint",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "xcresult-issues", targets: ["xcresult-issues"]),
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.1.1")),
    ],
    targets: [
        .executableTarget(
            name: "xcresult-issues",
            dependencies: [
                "XcresultIssues",
            ]
        ),
        .target(
            name: "XcresultIssues",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
