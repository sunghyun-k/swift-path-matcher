import Foundation

// MARK: - OptionalParameter Component

/// A path component that captures an optional path segment as a string parameter.
///
/// Use `OptionalParameter` when you need to capture a dynamic value that may or may not
/// be present in the URL path. Unlike ``Parameter``, this component will always succeed
/// in matching, returning `nil` if no path component is available at that position.
///
/// ## Example
///
/// ```swift
/// let userMatcher: PathMatcher<(String, String?)> = PathMatcher {
///     Literal("users")
///     Parameter()          // Required user ID
///     OptionalParameter()  // Optional additional info
/// }
///
/// // With optional parameter
/// let withOptional = userMatcher.match(["users", "john", "profile"])
/// print(withOptional?.0) // "john"
/// print(withOptional?.1) // "profile"
///
/// // Without optional parameter
/// let withoutOptional = userMatcher.match(["users", "john"])
/// print(withoutOptional?.0) // "john"
/// print(withoutOptional?.1) // nil
/// ```
///
/// ## Multiple Optional Parameters
///
/// ```swift
/// let apiMatcher: PathMatcher<(String?, String?, String?)> = PathMatcher {
///     Literal("api")
///     Literal("v1")
///     OptionalParameter()  // resource
///     OptionalParameter()  // id
///     OptionalParameter()  // action
/// }
///
/// // Partial matching
/// let partial = apiMatcher.match(["api", "v1", "users"])
/// // Returns: ("users", nil, nil)
/// ```
public struct OptionalParameter: PathComponent {
    public typealias Output = String?

    /// Creates a new optional parameter component.
    ///
    /// The optional parameter will capture a string value if available at the
    /// corresponding position, or return `nil` if no more path components exist.
    public init() {}

    /// The matcher implementation for this optional parameter component.
    public var matcher: PathPattern<String?> {
        PathPattern { components, index in
            if index < components.endIndex {
                let value = components[index]
                index += 1
                return value
            } else {
                return nil as String?
            }
        }
    }
}
