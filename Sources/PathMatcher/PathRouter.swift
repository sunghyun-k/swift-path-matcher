import Foundation

/// A router that manages multiple path patterns and dispatches URLs to their corresponding handlers.
///
/// `PathRouter` allows you to register multiple path patterns, each with an associated handler.
/// When a URL is passed to ``handle(_:)``, the router finds the first matching pattern
/// and invokes its handler with the extracted parameters.
///
/// ## Overview
///
/// Use `PathRouter` when you need to route URLs to different handlers based on their path structure.
/// Each route is defined using the same declarative syntax as ``PathMatcher``.
///
/// ```swift
/// var router = PathRouter()
///
/// router.append {
///     "users"
///     Parameter()
/// } handler: { url, userId in
///     print("User ID: \(userId)")
/// }
///
/// router.append {
///     "posts"
///     Parameter()
///     "comments"
///     Parameter()
/// } handler: { url, (postId, commentId) in
///     print("Post: \(postId), Comment: \(commentId)")
/// }
///
/// let url = URL(string: "https://example.com/users/123")!
/// router.handle(url)  // Prints: "User ID: 123"
/// ```
///
/// ## Route Matching Order
///
/// Routes are evaluated in the order they were added. The first matching route's handler
/// is invoked, and subsequent routes are not checked. If no route matches, no handler is called.
///
/// ## Topics
///
/// ### Creating a Router
///
/// - ``init()``
///
/// ### Registering Routes
///
/// - ``append(content:handler:)``
///
/// ### Handling URLs
///
/// - ``handle(_:)``
public struct PathRouter {
    private var handlers: [Handler<Any>] = []

    /// Creates a new, empty path router.
    public init() {}

    /// Registers a new route with its handler.
    ///
    /// Use this method to add a path pattern and its corresponding handler to the router.
    /// The handler receives both the original URL and the extracted parameters when the pattern matches.
    ///
    /// - Parameters:
    ///   - content: A result builder closure that defines the path pattern using ``PathComponent`` types.
    ///   - handler: A closure that is called when the pattern matches a URL.
    ///     The closure receives the original `URL` and the extracted output from the pattern.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var router = PathRouter()
    ///
    /// // Route with a single parameter
    /// router.append {
    ///     "api"
    ///     "users"
    ///     Parameter()
    /// } handler: { url, userId in
    ///     print("Fetching user \(userId) from \(url)")
    /// }
    ///
    /// // Route with multiple parameters
    /// router.append {
    ///     "api"
    ///     "users"
    ///     Parameter()
    ///     "posts"
    ///     Parameter()
    /// } handler: { url, (userId, postId) in
    ///     print("User \(userId)'s post \(postId)")
    /// }
    /// ```
    public mutating func append<C: PathComponent>(
        @PathMatcherBuilder content: () -> C,
        handler: @escaping (URL, C.Output) -> Void,
    ) {
        let matcher = PathMatcher { content() }
        handlers.append(Handler<Any>(
            matcher: matcher.match(_:),
            handler: { url, output in
                handler(url, output as! C.Output)
            },
        ))
    }

    /// Dispatches a URL to the first matching route's handler.
    ///
    /// This method iterates through registered routes in order and invokes the handler
    /// of the first route whose pattern matches the URL's path. If no route matches,
    /// no action is taken.
    ///
    /// The URL's path components are extracted (excluding the leading `/`), and each
    /// registered pattern is tested against these components.
    ///
    /// - Parameter url: The URL to route.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var router = PathRouter()
    /// router.append {
    ///     "users"
    ///     Parameter()
    /// } handler: { url, userId in
    ///     print("User: \(userId)")
    /// }
    ///
    /// let url = URL(string: "https://example.com/users/42")!
    /// router.handle(url)  // Prints: "User: 42"
    ///
    /// let unknownURL = URL(string: "https://example.com/unknown")!
    /// router.handle(unknownURL)  // No output (no matching route)
    /// ```
    public func handle(_ url: URL) {
        for handler in handlers {
            if let output = handler.matcher(Array(url.pathComponents.dropFirst())) {
                handler.handler(url, output)
                return
            }
        }
    }
}

private struct Handler<Output> {
    let matcher: ([String]) -> Output?
    let handler: (URL, Output) -> Void
}
