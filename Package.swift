// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "swift-path-matcher",
    products: [
        .library(
            name: "PathMatcher",
            targets: ["PathMatcher"]
        ),
        .library(
            name: "Example",
            targets: ["Example"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "PathMatcher"
        ),
        .target(
            name: "Example",
            dependencies: ["PathMatcher"]
        ),
        .testTarget(
            name: "PathMatcherTests",
            dependencies: ["PathMatcher"]
        ),
    ]
)
