import Foundation

// MARK: - Empty Component (Public but implementation detail)

/// A path component that matches empty paths (no path components).
///
/// This component is used internally by the result builder when you create
/// an empty path matcher. It's public to support the DSL syntax but is not
/// intended for direct use in typical scenarios.
///
/// ## Example
///
/// ```swift
/// let emptyMatcher: PathMatcher<Void> = PathMatcher {
///     // Empty block - uses Empty component internally
/// }
///
/// let result = emptyMatcher.match([])
/// print(result != nil) // true
/// ```
///
/// - Note: This type is part of the public API to support the result builder syntax,
///   but direct usage is not recommended for typical use cases.
public struct Empty: PathComponent {
    public typealias Output = Void

    /// Creates a new empty component.
    ///
    /// The empty component always succeeds in matching and consumes no path components.
    public init() {}

    /// The matcher implementation for this empty component.
    ///
    /// Always returns `()` (void) without consuming any path components.
    public var matcher: PathMatcherCore<Void> {
        PathMatcherCore { _, _ in () }
    }
}
