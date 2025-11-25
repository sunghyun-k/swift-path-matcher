// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "swift-path-matcher",
    products: [
        .library(
            name: "PathMatcher",
            targets: ["PathMatcher", "PathRouter"],
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
            name: "PathRouter",
            dependencies: ["PathMatcher"],
        ),
        .target(
            name: "Example",
            dependencies: ["PathRouter"],
        ),
        .testTarget(
            name: "PathMatcherTests",
            dependencies: ["PathMatcher"],
        ),
    ],
)
