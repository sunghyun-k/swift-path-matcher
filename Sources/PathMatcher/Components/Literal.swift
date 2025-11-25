import Foundation

// MARK: - Literal Component

/// A path component that matches an exact string literal.
///
/// Use `Literal` when you need to match a specific, fixed text segment in a URL path.
/// This component doesn't capture any value and produces `Void` when it matches.
///
/// ## Example
///
/// ```swift
/// let searchMatcher: PathMatcher<Void> = PathMatcher {
///     Literal("search")  // Matches exactly "search"
/// }
///
/// // Matches: ["search"]
/// // Doesn't match: ["Search"], ["search2"], ["searches"]
/// ```
///
/// ## Path-like Literals
///
/// When the literal value contains `/`, it will match multiple path components:
///
/// ```swift
/// let apiMatcher: PathMatcher<Void> = PathMatcher {
///     Literal("api/v2/books")  // Matches "api", "v2", "books" in sequence
/// }
///
/// // Matches: ["api", "v2", "books"]
/// ```
///
/// ## String Literal Syntax
///
/// You can also use string literals directly in the path matcher:
///
/// ```swift
/// let matcher: PathMatcher<String> = PathMatcher {
///     "api"
///     "users"
///     Parameter()
/// }
/// ```
public struct Literal: PathComponent, ExpressibleByStringLiteral {
    public typealias Output = Void
    private let segments: [String]
    private let caseInsensitive: Bool

    /// Creates a new literal component that matches the specified string.
    ///
    /// - Parameter value: The exact string that this component will match.
    ///   If the value contains `/`, it will be split and match multiple path components.
    /// - Parameter caseInsensitive: Whether to perform case-insensitive matching.
    ///   Defaults to `false` (case-sensitive matching).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let component = Literal("users")
    /// // Will match path component "users" exactly
    ///
    /// let multiComponent = Literal("api/v2/books")
    /// // Will match path components "api", "v2", "books" in sequence
    ///
    /// let caseInsensitiveComponent = Literal("users", caseInsensitive: true)
    /// // Will match "users", "Users", "USERS", etc.
    /// ```
    public init(_ value: String, caseInsensitive: Bool = false) {
        self.segments = value.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        self.caseInsensitive = caseInsensitive
    }

    /// Creates a literal component from a string literal.
    ///
    /// This initializer enables the string literal syntax in path matchers:
    ///
    /// ```swift
    /// let matcher: PathMatcher<String> = PathMatcher {
    ///     "api"      // Same as Literal("api")
    ///     "users"    // Same as Literal("users")
    ///     Parameter()
    /// }
    /// ```
    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// The pattern implementation for this literal component.
    public var pattern: PathPattern<Void> {
        PathPattern { components, index in
            for segment in segments {
                guard index < components.endIndex else {
                    return nil
                }

                let matches = caseInsensitive ?
                    components[index].lowercased() == segment.lowercased() :
                    components[index] == segment

                guard matches else {
                    return nil
                }

                index += 1
            }
            return ()
        }
    }
}
