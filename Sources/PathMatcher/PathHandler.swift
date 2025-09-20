import Foundation

public struct PathHandler {
    private typealias MatchAction = (
        matcher: ([String]) -> Any?,
        handler: (Any) -> Void
    )
    private var matchActions: [MatchAction] = []

    public init() {}

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

    public func handle(_ pathComponents: [String]) {
        for (matcher, action) in matchActions {
            if let matched = matcher(pathComponents) {
                action(matched)
                return
            }
        }
    }
}
