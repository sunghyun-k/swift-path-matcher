import Foundation

// MARK: - PathHandler

/// A handler that manages multiple path matchers and routes path components to appropriate handlers.
///
/// `PathHandler` provides a convenient way to handle deep links and URL routing by allowing you
/// to register multiple path patterns with their corresponding handler functions. When a path
/// is processed, the first matching pattern will have its handler executed.
///
/// ## Basic Usage
///
/// ```swift
/// var pathHandler = PathHandler()
///
/// // Register simple routes
/// pathHandler.add {
///     Literal("settings")
/// } handler: {
///     present(SettingsViewController())
/// }
///
/// // Register routes with parameters
/// pathHandler.add {
///     Literal("users")
///     Parameter()
/// } handler: { userID in
///     push(UserViewController(userID: userID))
/// }
///
/// // Handle incoming path
/// pathHandler.handle(["users", "123"])
/// ```
///
/// ## Complex Routing
///
/// ```swift
/// // Routes with multiple parameters
/// pathHandler.add {
///     Literal("users")
///     Parameter()
///     Literal("posts")
///     Parameter()
/// } handler: { userID, postID in
///     push(UserViewController(userID: userID))
///     push(PostViewController(postID: postID))
/// }
///
/// // Routes with optional parameters
/// pathHandler.add {
///     Literal("search")
///     OptionalParameter()
/// } handler: { query in
///     present(SearchViewController(query: query))
/// }
/// ```
///
/// - Note: Routes are matched in the order they were added. The first matching route will be executed.
public struct PathHandler {
    private typealias MatchAction = (
        matcher: ([String]) -> Any?,
        handler: (Any) -> Void
    )
    private var matchActions: [MatchAction] = []

    /// Creates a new path handler with no registered routes.
    ///
    /// Use the ``add(_:handler:)`` method to register path patterns and their handlers.
    public init() {}

    /// Registers a new path pattern with its corresponding handler function.
    ///
    /// - Parameters:
    ///   - content: A result builder closure that defines the path pattern using components
    ///     like `Literal`, `Parameter`, and `OptionalParameter`.
    ///   - handler: A closure that will be executed when the path pattern matches.
    ///     The closure receives the extracted values from the path components as parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var pathHandler = PathHandler()
    ///
    /// // Route with no parameters
    /// pathHandler.add {
    ///     Literal("about")
    /// } handler: {
    ///     showAboutPage()
    /// }
    ///
    /// // Route with single parameter
    /// pathHandler.add {
    ///     Literal("users")
    ///     Parameter()
    /// } handler: { userID in
    ///     showUserProfile(userID: userID)
    /// }
    ///
    /// // Route with multiple parameters
    /// pathHandler.add {
    ///     Literal("users")
    ///     Parameter()
    ///     Literal("posts")
    ///     Parameter()
    /// } handler: { userID, postID in
    ///     showUserPost(userID: userID, postID: postID)
    /// }
    /// ```
    ///
    /// - Note: Routes are matched in the order they were added. Ensure more specific
    ///   routes are added before more general ones.
    public mutating func add<C: PathComponent>(
        @PathMatcherBuilder content: () -> C,
        handler: @escaping (C.Output) -> Void,
    ) {
        let matcher = PathMatcher {
            content()
        }
        let matchAction = MatchAction(
            matcher: { matcher.match($0) },
            handler: { handler($0 as! C.Output) },
        )
        matchActions.append(matchAction)
    }

    /// Processes the given path components against all registered routes.
    ///
    /// This method attempts to match the provided path components against each registered
    /// route in the order they were added. When a match is found, the corresponding handler
    /// is executed and processing stops.
    ///
    /// - Parameter pathComponents: An array of path components to match against registered routes.
    ///   Typically obtained by splitting a URL path by "/".
    ///
    /// ## Example
    ///
    /// ```swift
    /// var pathHandler = PathHandler()
    ///
    /// pathHandler.add {
    ///     Literal("users")
    ///     Parameter()
    /// } handler: { userID in
    ///     print("User ID: \(userID)")
    /// }
    ///
    /// // Extract path components from URL
    /// let url = URL(string: "https://example.com/users/john")!
    /// let pathComponents = Array(url.pathComponents.dropFirst()) // ["users", "john"]
    ///
    /// // Handle the path
    /// pathHandler.handle(pathComponents) // Prints: "User ID: john"
    /// ```
    ///
    /// - Note: If no routes match the provided path components, no action is taken.
    ///   Only the first matching route will be executed.
    public func handle(_ pathComponents: [String]) {
        for (matcher, action) in matchActions {
            if let matched = matcher(pathComponents) {
                action(matched)
                return
            }
        }
    }
}
