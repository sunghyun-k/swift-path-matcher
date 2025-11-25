# PathMatcher

A Swift library for pattern matching URL path components using a declarative DSL with result builders.

> **⚠️ Note:** This library is currently under development.

## Features

- **Declarative DSL**: Build path matchers using a clean, readable syntax with Swift result builders
- **Type-safe**: Capture path parameters with full type safety and compile-time guarantees
- **Optional Parameters**: Support for optional path segments with automatic handling
- **Deep Link Support**: Built-in `PathRouter` for easy deep link routing

## Installation

### Swift Package Manager

Add PathMatcher to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/swift-path-matcher.git", from: "0.1.5")
]
```

Or add it through Xcode: **File → Add Package Dependencies** → Enter repository URL

## Quick Start

### Basic Usage

```swift
import PathMatcher

// Extract path components from URL
let url = URL(string: "https://github.com/settings/profile")!
let pathComponents = Array(url.pathComponents.dropFirst()) // ["settings", "profile"]

// Create a simple matcher
let profileSettingsMatcher: PathMatcher<Void> = PathMatcher {
    Literal("settings")
    Literal("profile")
}

// Match returns non-nil if successful
let result: Void? = profileSettingsMatcher.match(pathComponents)
print(result != nil) // true
```

### Case-Insensitive Matching

Use the `caseInsensitive` parameter for flexible text matching:

```swift
// Case-insensitive matcher
let apiMatcher: PathMatcher<Void> = PathMatcher {
    Literal("api", caseInsensitive: true)
    Literal("v1", caseInsensitive: true)
}

// All of these will match:
apiMatcher.match(["api", "v1"])     // ✓
apiMatcher.match(["API", "V1"])     // ✓
apiMatcher.match(["Api", "v1"])     // ✓
apiMatcher.match(["api", "V1"])     // ✓
```

### Parameter Capture

Capture dynamic path segments as strongly-typed parameters. The output type is automatically inferred at compile time based on the order and count of `Parameter` and `OptionalParameter` components used in the PathMatcherBuilder:

```swift
// Match pattern: "owners/:owner"
let ownerMatcher: PathMatcher<String> = PathMatcher {
    Literal("owners")
    Parameter() // captures the owner name
}

let result: String? = ownerMatcher.match(["owners", "swiftlang"])
print(result) // Optional("swiftlang")
```

### Optional Parameters

Handle optional path segments with automatic type inference:

```swift
// Match pattern: "owners/:owner/:repo?"
let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
    Literal("owners")
    Parameter() // required: owner
    OptionalParameter() // optional: repo
}

// With optional parameter
if let (owner, repo) = repoMatcher.match(["owners", "swiftlang", "swift"]) {
    print(owner) // "swiftlang"
    print(repo) // Optional("swift")
}

// Without optional parameter
if let (owner, repo) = repoMatcher.match(["owners", "swiftlang"]) {
    print(owner) // "swiftlang"
    print(repo) // nil
}
```

> **⚠️ Important:** Optional parameters must always be placed at the end of the pattern.

## Deep Link Handling with PathRouter

`PathRouter` provides a convenient way to handle deep links and URL routing:

```swift
import PathRouter

var router = PathRouter()

// Simple routes
router.append {
    Literal("settings")
} handler: { url in
    present(SettingsViewController())
}

// Routes with parameters
router.append {
    Literal("users")
    Parameter()
} handler: { url, userID in
    push(UserViewController(userID: userID))
}

// Complex nested routes with multiple parameters
router.append {
    Literal("users")
    Parameter()
    Literal("bookmarks")
    Parameter()
} handler: { url, params in
    let (userID, bookmarkID) = params
    push(UserViewController(userID: userID))
    push(BookmarkViewController(bookmarkID: bookmarkID))
}

// Routes with optional parameters
router.append {
    Literal("search")
    OptionalParameter()
} handler: { url, query in
    if let query = query {
        present(SearchViewController(query: query))
    } else {
        present(SearchViewController())
    }
}

// Handle incoming URL
let url = URL(string: "https://example.com/users/123/bookmarks/456")!
router.handle(url)
```

## Available Components

### Built-in Components

| Component | Description | Output Type |
|-----------|-------------|-------------|
| `Literal("text")` | Matches exact text | `Void` |
| `Literal("text", caseInsensitive: true)` | Matches text ignoring case | `Void` |
| `Parameter()` | Captures a required path segment | `String` |
| `OptionalParameter()` | Captures an optional path segment | `String?` |

### Creating Custom Components

Extend functionality by creating custom components that conform to `PathComponent`:

```swift
public struct UUIDParameter: PathComponent {
    public typealias Output = UUID
    
    public var pattern: PathPattern<UUID> {
        PathPattern { components, index in
            guard index < components.endIndex,
                  let uuid = UUID(uuidString: components[index]) else {
                return nil
            }
            index += 1
            return uuid
        }
    }
}

// Usage example
let userMatcher: PathMatcher<UUID> = PathMatcher {
    Literal("users")
    UUIDParameter() // Only matches valid UUID strings
}

let result = userMatcher.match(["users", "550e8400-e29b-41d4-a716-446655440000"])
// Returns: UUID("550e8400-e29b-41d4-a716-446655440000")
```

Custom components can implement any validation or transformation logic:

```swift
public struct IntParameter: PathComponent {
    public typealias Output = Int
    
    public var pattern: PathPattern<Int> {
        PathPattern { components, index in
            guard index < components.endIndex,
                  let intValue = Int(components[index]) else {
                return nil
            }
            index += 1
            return intValue
        }
    }
}
```

## Advanced Usage

### Complex Pattern Matching

```swift
// Match pattern: "api/v1/users/:id/posts/:postId?"
let apiMatcher: PathMatcher<(String, String?)> = PathMatcher {
    Literal("api")
    Literal("v1")
    Literal("users")
    Parameter() // user ID
    Literal("posts")
    OptionalParameter() // optional post ID
}
```

### Type Safety

PathMatcher leverages Swift's type system to ensure compile-time safety:

```swift
// Compiler knows the exact return type
let userMatcher: PathMatcher<String> = PathMatcher {
    Literal("users")
    Parameter()
}

// Type-safe parameter handling
if let userID = userMatcher.match(pathComponents) {
    // userID is guaranteed to be String
    loadUser(userID)
}
```

## Requirements

- **Swift**: 6.1 or later

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
