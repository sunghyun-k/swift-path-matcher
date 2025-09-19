import Foundation

// MARK: - PathMatcherCore (Public but implementation detail)

/// The core matching engine that implements the actual pattern matching logic.
///
/// This type is public to support the DSL syntax but is considered an implementation detail.
/// Most users should interact with ``PathMatcher`` and ``PathComponent`` types instead.
///
/// - Note: This type is part of the public API to support the result builder syntax,
///   but direct usage is not recommended for typical use cases.
public struct PathMatcherCore<Output> {
    let matchFunction: ([String], inout Int) -> Output?

    /// Creates a new core matcher with the specified matching function.
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

// MARK: - PathMatcherCore as PathComponent

extension PathMatcherCore: PathComponent {
    /// Conforms to ``PathComponent`` by returning itself as the matcher.
    public var matcher: PathMatcherCore<Output> { self }
}
