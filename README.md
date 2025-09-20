# PathMatcher

A Swift library for pattern matching URL path components using a declarative DSL with result builders.

> **⚠️ Note:** This library is currently under development.

## Features

- **Declarative DSL**: Build path matchers using a clean, readable syntax with Swift result builders
- **Type-safe**: Capture path parameters with full type safety and compile-time guarantees
- **Optional Parameters**: Support for optional path segments with automatic handling
- **Deep Link Support**: Built-in `PathHandler` for easy deep link routing

## Installation

### Swift Package Manager

Add PathMatcher to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/swift-path-matcher.git", from: "0.1.0")
]
```

Or add it through Xcode: **File → Add Package Dependencies** → Enter repository URL

## Quick Start

### Basic Usage

```swift
import PathMatcher

// Extract path components from URL
let url = URL(string: "https://github.com/settings/profile")!
let pathComponents = Array(url.pathComponents.dropFirst())

// Create a simple matcher
let profileSettingsMatcher: PathMatcher<Void> = PathMatcher {
    Literal("settings")
    Literal("profile")
}

// Match returns non-nil if successful
let result: Void? = profileSettingsMatcher.match(pathComponents)
print(result != nil) // true
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
let withRepo = repoMatcher.match(["owners", "swiftlang", "swift"])
print(withRepo?.0) // "swiftlang"
print(withRepo?.1) // Optional("swift")

// Without optional parameter
let withoutRepo = repoMatcher.match(["owners", "swiftlang"])
print(withoutRepo?.0) // "swiftlang"
print(withoutRepo?.1) // nil
```

> **⚠️ Important:** Optional parameters must always be placed at the end of the pattern.

## Deep Link Handling with PathHandler

`PathHandler` provides a convenient way to handle deep links and URL routing:

```swift
import PathMatcher

var pathHandler = PathHandler()

// Simple routes
pathHandler.add {
    Literal("settings")
} handler: {
    present(SettingsViewController())
}

// Routes with parameters
pathHandler.add {
    Literal("users")
    Parameter()
} handler: { userID in
    push(UserViewController(userID: userID))
}

// Complex nested routes
pathHandler.add {
    Literal("users")
    Parameter()
    Literal("bookmarks")
    Parameter()
} handler: { userID, bookmarkID in
    push(UserViewController(userID: userID))
    push(BookmarkViewController(bookmarkID: bookmarkID))
}

// Handle incoming path
pathHandler.handle(["users", "123", "bookmarks", "456"])
```

## Available Components

### Built-in Components

| Component | Description | Output Type |
|-----------|-------------|-------------|
| `Literal("text")` | Matches exact text | `Void` |
| `Parameter()` | Captures a required path segment | `String` |
| `OptionalParameter()` | Captures an optional path segment | `String?` |

### Creating Custom Components

Extend functionality by creating custom components that conform to `PathComponent`:

```swift
public struct CustomComponent: PathComponent {
    public typealias Output = YourCustomType
    
    public var matcher: PathPattern<YourCustomType> {
        PathPattern { components, index in
            // Implement your custom matching logic
            // Return (matched_value, consumed_components_count) or nil
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

- **Swift**: 5.9 or later

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
