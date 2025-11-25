# ``PathMatcher``

A declarative, type-safe URL path matching library for Swift.

## Overview

PathMatcher provides a clean DSL for defining URL path patterns and extracting typed parameters.
Using Swift's result builder feature, you can create complex routing patterns with minimal boilerplate.

```swift
let matcher: PathMatcher<(String, String)> = PathMatcher {
    "api"
    "users"
    Parameter()
    "posts"
    Parameter()
}

if let (userId, postId) = matcher.match(["api", "users", "123", "posts", "456"]) {
    print("User: \(userId), Post: \(postId)")
}
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``PathMatcher/PathMatcher``
- ``PathRouter``
- ``PathComponent``

### Components

- ``Literal``
- ``Parameter``
- ``OptionalParameter``

### Advanced

- ``PathPattern``
- ``PathMatcherBuilder``
