import Foundation

// MARK: - PathPattern (Public but implementation detail)

/// A reusable pattern that can match path segments and extract values.
///
/// This type represents a composable path matching pattern with a specific output type.
/// It is public to support the DSL syntax but is considered an implementation detail.
/// Most users should interact with ``PathMatcher`` and ``PathComponent`` types instead.
///
/// - Note: This type is part of the public API to support the result builder syntax,
///   but direct usage is not recommended for typical use cases.
public struct PathPattern<Output> {
    let matchFunction: ([String], inout Int) -> Output?

    /// Creates a new path pattern with the specified matching function.
    ///
    /// - Parameter matchFunction: A closure that takes an array of path components
    ///   and an index, and returns the matched value or `nil` if no match.
    ///   The index is modified in-place to track the current position in the components array.
    public init(_ matchFunction: @escaping ([String], inout Int) -> Output?) {
        self.matchFunction = matchFunction
    }

    /// Performs the matching operation starting at the given index.
    ///
    /// - Parameters:
    ///   - components: The array of path components to match against.
    ///   - index: The current index in the components array. This value is modified
    ///     in-place as components are consumed during matching.
    ///
    /// - Returns: The matched value of type `Output` if successful, or `nil` if no match.
    func match(_ components: [String], _ index: inout Int) -> Output? {
        matchFunction(components, &index)
    }
}

// MARK: - PathPattern as PathComponent

extension PathPattern: PathComponent {
    /// Conforms to ``PathComponent`` by returning itself as the pattern.
    public var matcher: PathPattern<Output> { self }
}
