// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "swift-path-matcher",
    products: [
        .library(
            name: "PathMatcher",
            targets: ["PathMatcher"],
        ),
    ],
    targets: [
        .target(
            name: "PathMatcher",
        ),
        .testTarget(
            name: "PathMatcherTests",
            dependencies: ["PathMatcher"],
        ),
    ],
)
