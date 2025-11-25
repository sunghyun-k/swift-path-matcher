// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "swift-path-matcher",
    products: [
        .library(
            name: "PathMatcher",
            targets: ["PathMatcher"],
        ),
        .library(
            name: "Example",
            targets: ["Example"],
        ),
    ],
    targets: [
        .target(
            name: "PathMatcher",
        ),
        .target(
            name: "Example",
            dependencies: ["PathMatcher"],
        ),
        .testTarget(
            name: "PathMatcherTests",
            dependencies: ["PathMatcher"],
        ),
    ],
)
