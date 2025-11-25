import Foundation

// MARK: - PathMatcherBuilder

/// A result builder that enables the declarative DSL syntax for creating path matchers.
///
/// This result builder allows you to use a clean, declarative syntax when defining
/// path patterns with multiple components.
///
/// ## Usage
///
/// ```swift
/// let matcher: PathMatcher<String> = PathMatcher {
///     Literal("api")      // These components are combined
///     Literal("users")    // using the result builder
///     Parameter()         // to create a single matcher
/// }
/// ```
///
/// - Note: This is used automatically when you use the `PathMatcher` initializer.
///   You typically don't need to interact with this type directly.
@resultBuilder
public enum PathMatcherBuilder {
    /// Builds an empty path matcher that matches empty paths.
    ///
    /// - Returns: An ``Empty`` component that matches when no path components are present.
    public static func buildBlock() -> Empty {
        Empty()
    }

    /// Builds a path matcher from a single component.
    ///
    /// - Parameter component: The single path component to use.
    /// - Returns: A ``PathPattern`` that implements the component's matching logic.
    public static func buildPartialBlock<Component: PathComponent>(
        first component: Component,
    ) -> PathPattern<Component.Output> {
        component.pattern
    }

    /// Converts a path component into a form that can be used by the result builder.
    ///
    /// - Parameter component: The path component to convert.
    /// - Returns: The same component, unchanged.
    public static func buildExpression<Component: PathComponent>(_ component: Component) -> Component {
        component
    }

    /// Converts a string literal into a ``Literal`` component.
    ///
    /// This enables using string literals directly in the path matcher DSL:
    ///
    /// ```swift
    /// let matcher: PathMatcher<String> = PathMatcher {
    ///     "api"      // Automatically converted to Literal("api")
    ///     "users"
    ///     Parameter()
    /// }
    /// ```
    ///
    /// - Parameter value: The string to match as a literal path component.
    /// - Returns: A ``Literal`` component matching the given string.
    public static func buildExpression(_ value: String) -> Literal {
        Literal(value)
    }
}
