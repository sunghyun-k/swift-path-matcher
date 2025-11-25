# Getting Started with PathMatcher

Learn how to use PathMatcher for URL routing in your Swift application.

## Overview

PathMatcher helps you build type-safe URL routing with a declarative syntax.
This guide walks you through the basic concepts and common use cases.

## Installation

Add PathMatcher to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/swift-path-matcher.git", from: "0.1.5")
]
```

Then add it as a dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["PathMatcher"]
)
```

## Basic Matching

The simplest matcher uses string literals to match exact path segments:

```swift
import PathMatcher

let matcher: PathMatcher<Void> = PathMatcher {
    "api"
    "v1"
    "users"
}

// Matches ["api", "v1", "users"]
matcher.match(["api", "v1", "users"]) // Returns ()
matcher.match(["api", "v2", "users"]) // Returns nil
```

## Capturing Parameters

Use ``Parameter`` to capture path segments:

```swift
let userMatcher: PathMatcher<String> = PathMatcher {
    "users"
    Parameter()
}

let userId = userMatcher.match(["users", "123"]) // Returns "123"
```

Multiple parameters create tuples:

```swift
let postMatcher: PathMatcher<(String, String)> = PathMatcher {
    "users"
    Parameter()
    "posts"
    Parameter()
}

if let (userId, postId) = postMatcher.match(["users", "123", "posts", "456"]) {
    print("User: \(userId), Post: \(postId)")
}
```

## Optional Parameters

Use ``OptionalParameter`` for segments that may or may not be present:

```swift
let searchMatcher: PathMatcher<(String, String?)> = PathMatcher {
    "search"
    Parameter()
    OptionalParameter()
}

searchMatcher.match(["search", "swift", "ios"])  // ("swift", "ios")
searchMatcher.match(["search", "swift"])         // ("swift", nil)
```

## Using PathRouter

``PathRouter`` manages multiple patterns and routes URLs:

```swift
let router = PathRouter()

router.append {
    "users"
    Parameter()
} handler: { userId in
    print("Viewing user: \(userId)")
}

router.append {
    "posts"
    Parameter()
} handler: { postId in
    print("Viewing post: \(postId)")
}

let url = URL(string: "https://example.com/users/123")!
router.handle(url)  // Prints: "Viewing user: 123"
```

## Case-Insensitive Matching

For case-insensitive matching, use ``Literal`` explicitly:

```swift
let matcher: PathMatcher<String> = PathMatcher {
    Literal("api", caseInsensitive: true)
    "users"
    Parameter()
}

// Both match:
matcher.match(["api", "users", "123"])
matcher.match(["API", "users", "123"])
```

## Multi-Segment Literals

String literals can contain path separators:

```swift
let matcher: PathMatcher<String> = PathMatcher {
    "api/v2/users"
    Parameter()
}

// Matches ["api", "v2", "users", "123"]
```

## Next Steps

- Explore the ``PathMatcher`` API documentation
- Check out the Example app in the repository
- Learn about creating custom components with ``PathComponent``
