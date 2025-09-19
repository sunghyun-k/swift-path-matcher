# PathMatcher

A Swift library for pattern matching URL path components using a declarative DSL with result builders.

## Features

- **Declarative DSL**: Build path matchers using a clean, readable syntax
- **Type-safe**: Capture path parameters with full type safety
- **Optional Parameters**: Support for optional path segments
- **Result Builders**: Leverage Swift's result builder feature for intuitive syntax
- **Zero Dependencies**: Pure Swift implementation with no external dependencies

## Installation

### Swift Package Manager

Add PathMatcher to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/swift-path-matcher.git", from: "1.0.0")
]
```

Or add it through Xcode: File → Add Package Dependencies → Enter repository URL

## Usage

### Basic Literal Matching

```swift
import PathMatcher

// Match exact path: "search"
let searchMatcher: PathMatcher<Void> = PathMatcher {
    Literal("search")
}

let result = searchMatcher.match(["search"])
print(result != nil) // true
```

### Parameter Capture

```swift
// Match path with parameter: "users/:owner"
let userMatcher: PathMatcher<String> = PathMatcher {
    Literal("users")
    Parameter() // captures the owner name
}

let result = userMatcher.match(["users", "swiftlang"])
print(result) // "swiftlang"
```

### Optional Parameters

```swift
// Match path with optional parameter: "users/:owner/:repo?"
let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
    Literal("users")
    Parameter() // owner
    OptionalParameter() // repo (optional)
}

// With repo
let withRepo = repoMatcher.match(["users", "swiftlang", "swift"])
print(withRepo?.0) // "swiftlang"
print(withRepo?.1) // "swift"

// Without repo
let withoutRepo = repoMatcher.match(["users", "swiftlang"])
print(withoutRepo?.0) // "swiftlang"  
print(withoutRepo?.1) // nil
```

### Multiple Optional Parameters

```swift
// API endpoint: "api/v1/:resource?/:id?/:action?"
let apiMatcher: PathMatcher<(String?, String?, String?)> = PathMatcher {
    Literal("api")
    Literal("v1")
    OptionalParameter() // resource
    OptionalParameter() // id
    OptionalParameter() // action
}

// All parameters present
let full = apiMatcher.match(["api", "v1", "users", "123", "edit"])
// Returns: ("users", "123", "edit")

// Partial parameters
let partial = apiMatcher.match(["api", "v1", "users"])
// Returns: ("users", nil, nil)

// No optional parameters
let minimal = apiMatcher.match(["api", "v1"])
// Returns: (nil, nil, nil)
```

## Components

### Available Components

- **`Literal("text")`**: Matches exact text
- **`Parameter()`**: Captures a required path segment as `String`
- **`OptionalParameter()`**: Captures an optional path segment as `String?`

### Custom Components

You can create custom components by conforming to the `PathComponent` protocol:

```swift
public struct CustomComponent: PathComponent {
    public typealias Output = YourType
    
    public var matcher: PathMatcherCore<YourType> {
        PathMatcherCore { components, index in
            // Your matching logic here
        }
    }
}
```

## API Reference

### PathMatcher

```swift
public struct PathMatcher<Output> {
    public init<Component: PathComponent>(
        @PathMatcherBuilder _ content: () -> Component
    ) where Component.Output == Output
    
    public func match(_ components: [String]) -> Output?
}
```

### PathComponent

```swift
public protocol PathComponent<Output> {
    associatedtype Output
    var matcher: PathMatcherCore<Output> { get }
}
```

## Examples

### GitHub-style Paths

```swift
// User profile: github.com/users/swiftlang
let userProfileMatcher: PathMatcher<String> = PathMatcher {
    Literal("users")
    Parameter() // username
}

// Repository: github.com/users/swiftlang/swift
let repositoryMatcher: PathMatcher<(String, String?)> = PathMatcher {
    Literal("users")
    Parameter() // username
    OptionalParameter() // repository name
}
```

### REST API Endpoints

```swift
// GET /api/users/123
let getUserMatcher: PathMatcher<String> = PathMatcher {
    Literal("api")
    Literal("users")
    Parameter() // user ID
}

// GET /api/users/123/posts/456
let getPostMatcher: PathMatcher<(String, String)> = PathMatcher {
    Literal("api")
    Literal("users")
    Parameter() // user ID
    Literal("posts")
    Parameter() // post ID
}
```

## Testing

Run tests using Swift Package Manager:

```bash
swift test
```

The library includes comprehensive tests covering all features and edge cases.

## Requirements

- Swift 5.9+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
