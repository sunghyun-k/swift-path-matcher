import Foundation

// MARK: - Parameter Component

/// A path component that captures a required path segment as a string parameter.
///
/// Use `Parameter` when you need to capture a dynamic value from a specific position
/// in the URL path. The parameter will fail to match if no path component is available
/// at that position.
///
/// ## Example
///
/// ```swift
/// let userMatcher: PathMatcher<String> = PathMatcher {
///     Literal("users")
///     Parameter()  // Captures the user ID
/// }
///
/// let result = userMatcher.match(["users", "john"])
/// print(result) // "john"
/// ```
///
/// ## Multiple Parameters
///
/// ```swift
/// let postMatcher: PathMatcher<(String, String)> = PathMatcher {
///     Literal("users")
///     Parameter()  // user ID
///     Literal("posts")
///     Parameter()  // post ID
/// }
///
/// let result = postMatcher.match(["users", "john", "posts", "123"])
/// print(result?.0) // "john"
/// print(result?.1) // "123"
/// ```
public struct Parameter: PathComponent {
    public typealias Output = String

    /// Creates a new parameter component.
    ///
    /// The parameter will capture any non-empty string from the corresponding
    /// position in the path components array.
    public init() {}

    /// The pattern implementation for this parameter component.
    public var pattern: PathPattern<String> {
        PathPattern { components, index in
            guard index < components.endIndex else {
                return nil
            }
            let value = components[index]
            index += 1
            return value
        }
    }
}
