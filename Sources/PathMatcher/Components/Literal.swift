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
/// ## Multiple Literals
///
/// ```swift
/// let apiMatcher: PathMatcher<Void> = PathMatcher {
///     Literal("api")
///     Literal("v1")
///     Literal("users")
/// }
///
/// // Matches: ["api", "v1", "users"]
/// ```
public struct Literal: PathComponent {
    public typealias Output = Void
    private let value: String

    /// Creates a new literal component that matches the specified string.
    ///
    /// - Parameter value: The exact string that this component will match.
    ///   The matching is case-sensitive.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let component = Literal("users")
    /// // Will match path component "users" exactly
    /// ```
    public init(_ value: String) {
        self.value = value
    }

    /// The matcher implementation for this literal component.
    public var matcher: PathMatcherCore<Void> {
        PathMatcherCore { components, index in
            guard index < components.endIndex, components[index] == value else {
                return nil
            }
            index += 1
            return ()
        }
    }
}
