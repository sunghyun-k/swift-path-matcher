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
    private let caseInsensitive: Bool

    /// Creates a new literal component that matches the specified string.
    ///
    /// - Parameter value: The exact string that this component will match.
    /// - Parameter caseInsensitive: Whether to perform case-insensitive matching.
    ///   Defaults to `false` (case-sensitive matching).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let component = Literal("users")
    /// // Will match path component "users" exactly
    ///
    /// let caseInsensitiveComponent = Literal("users", caseInsensitive: true)
    /// // Will match "users", "Users", "USERS", etc.
    /// ```
    public init(_ value: String, caseInsensitive: Bool = false) {
        self.value = value
        self.caseInsensitive = caseInsensitive
    }

    /// The pattern implementation for this literal component.
    public var pattern: PathPattern<Void> {
        PathPattern { components, index in
            guard index < components.endIndex else {
                return nil
            }
            
            let matches = caseInsensitive ? 
                components[index].lowercased() == value.lowercased() :
                components[index] == value
            
            guard matches else {
                return nil
            }
            
            index += 1
            return ()
        }
    }
}
