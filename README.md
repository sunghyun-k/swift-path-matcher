# PathMatcher

**Declarative URL path matching library using Swift Result Builders**

```swift
let matcher: PathMatcher<(String, String?)> = PathMatcher {
    "users"
    Parameter()           // required: user ID
    OptionalParameter()   // optional: additional path
}

matcher.match(["users", "john", "profile"]) // ("john", "profile")
matcher.match(["users", "john"])            // ("john", nil)
```

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/swift-path-matcher.git", from: "0.1.5")
]
```

## Core Components

| Component | Description | Output Type |
|-----------|-------------|-------------|
| `"path"` | Matches exact string (String Literal) | `Void` |
| `Literal("path")` | Matches exact string (explicit) | `Void` |
| `Parameter()` | Captures required path segment | `String` |
| `OptionalParameter()` | Captures optional segment | `String?` |

## Usage

### Basic Matching

```swift
import PathMatcher

let searchMatcher: PathMatcher<Void> = PathMatcher {
    "search"
}

searchMatcher.match(["search"])  // () - success
searchMatcher.match(["profile"]) // nil - failure
```

### String Literal Syntax

You can use string literals directly instead of `Literal()`:

```swift
// These two matchers are equivalent
let matcher1: PathMatcher<String> = PathMatcher {
    Literal("api")
    Literal("users")
    Parameter()
}

let matcher2: PathMatcher<String> = PathMatcher {
    "api"
    "users"
    Parameter()
}
```

Use explicit `Literal()` when you need case-insensitive matching.

### Multi-Segment Literals

String literals can match multiple segments separated by `/`:

```swift
// All three matchers work identically
let matcher1 = PathMatcher { "api"; "v2"; "books" }
let matcher2 = PathMatcher { "api/v2/books" }
let matcher3 = PathMatcher { Literal("api/v2/books") }

// All match ["api", "v2", "books"]
```

### Case-Insensitive Matching

```swift
let matcher = PathMatcher {
    Literal("API/V2", caseInsensitive: true)
}

matcher.match(["api", "v2"])   // success
matcher.match(["API", "V2"])   // success
matcher.match(["Api", "v2"])   // success
```

### Parameter Capture

```swift
// Pattern: "owners/:owner"
let ownerMatcher: PathMatcher<String> = PathMatcher {
    "owners"
    Parameter()
}

ownerMatcher.match(["owners", "swiftlang"]) // "swiftlang"
```

### Multiple Parameters

Multiple parameters are automatically flattened into tuples:

```swift
// Pattern: "users/:userId/posts/:postId"
let postMatcher: PathMatcher<(String, String)> = PathMatcher {
    "users"
    Parameter()      // userId
    "posts"
    Parameter()      // postId
}

let result = postMatcher.match(["users", "john", "posts", "123"])
// result?.0 == "john", result?.1 == "123"
```

### Optional Parameters

```swift
// Pattern: "owners/:owner/:repo?"
let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
    "owners"
    Parameter()         // required
    OptionalParameter() // optional
}

repoMatcher.match(["owners", "swift", "nio"]) // ("swift", "nio")
repoMatcher.match(["owners", "swift"])        // ("swift", nil)
```

## PathRouter

Register multiple path patterns and route URLs:

```swift
var router = PathRouter()

router.append {
    "settings"
} handler: { url, _ in
    showSettings()
}

router.append {
    "users"
    Parameter()
} handler: { url, userID in
    showUser(id: userID)
}

router.append {
    "posts"
    Parameter()
    OptionalParameter()
} handler: { url, params in
    let (postID, action) = params
    showPost(id: postID, action: action)
}

// Handle URL - executes first matching handler
router.handle(URL(string: "myapp:///users/john")!)
```

## Custom Components

Create your own components by implementing the `PathComponent` protocol:

```swift
struct IntParameter: PathComponent {
    typealias Output = Int

    var pattern: PathPattern<Int> {
        PathPattern { components, index in
            guard index < components.endIndex,
                  let value = Int(components[index]) else {
                return nil
            }
            index += 1
            return value
        }
    }
}

// Usage
let matcher: PathMatcher<Int> = PathMatcher {
    "posts"
    IntParameter()  // matches integers only
}

matcher.match(["posts", "123"])   // 123
matcher.match(["posts", "abc"])   // nil
```

## Type System

The Result Builder automatically handles type composition:

- `Void + Void → Void`
- `Void + T → T`
- `T + Void → T`
- `T1 + T2 → (T1, T2)`
- `(T1, T2) + T3 → (T1, T2, T3)` (flattened up to 6 elements)

## Example App

A deep link routing demo using SwiftUI and NavigationStack is included.

Run Xcode Preview in `Sources/Example/ContentView.swift` to try it out.

## Requirements

- Swift 6.1+

## License

MIT License
