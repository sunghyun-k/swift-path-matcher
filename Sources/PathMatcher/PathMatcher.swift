import Foundation

// MARK: - PathMatcher

/// A path matcher that uses a declarative DSL to match URL path components.
///
/// `PathMatcher` allows you to define path patterns using a result builder syntax
/// and extract typed values from matching paths.
///
/// ## Basic Usage
///
/// ```swift
/// // Match exact path: "search"
/// let searchMatcher: PathMatcher<Void> = PathMatcher {
///     Literal("search")
/// }
///
/// // Match path with parameter: "users/:owner"
/// let userMatcher: PathMatcher<String> = PathMatcher {
///     Literal("users")
///     Parameter() // captures the owner name
/// }
/// ```
///
/// ## Multiple Parameters
///
/// ```swift
/// // Match path with multiple parameters: "users/:owner/:repo?"
/// let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
///     Literal("users")
///     Parameter() // owner
///     OptionalParameter() // repo (optional)
/// }
/// ```
public struct PathMatcher<Output> {
    private let pattern: PathPattern<Output>

    /// Creates a new path matcher with the specified component configuration.
    ///
    /// - Parameter content: A result builder closure that defines the path pattern
    ///   using components like `Literal`, `Parameter`, and `OptionalParameter`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let matcher: PathMatcher<String> = PathMatcher {
    ///     Literal("api")
    ///     Literal("users")
    ///     Parameter() // user ID
    /// }
    /// ```
    public init<Component: PathComponent>(@PathMatcherBuilder _ content: () -> Component)
        where Component.Output == Output
    {
        pattern = content().matcher
    }

    /// Attempts to match the given path components against this matcher's pattern.
    ///
    /// - Parameter components: An array of path components to match against.
    ///   Typically obtained by splitting a URL path by "/".
    ///
    /// - Returns: The extracted value of type `Output` if the path matches,
    ///   or `nil` if it doesn't match.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let matcher: PathMatcher<String> = PathMatcher {
    ///     Literal("users")
    ///     Parameter()
    /// }
    ///
    /// let result = matcher.match(["users", "john"])
    /// print(result) // "john"
    ///
    /// let noMatch = matcher.match(["posts", "123"])
    /// print(noMatch) // nil
    /// ```
    ///
    /// - Note: The matcher requires an exact match of all components.
    ///   Extra or missing components will result in a failed match.
    public func match(_ components: [String]) -> Output? {
        var index = components.startIndex
        return pattern.match(components, &index).flatMap { result in
            // 전체 컴포넌트를 매칭했는지 확인
            index == components.endIndex ? result : nil
        }
    }
}
