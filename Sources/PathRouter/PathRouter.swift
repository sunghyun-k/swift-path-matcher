import Foundation
@_exported import PathMatcher

public struct PathRouter {
    private var handlers: [Handler<Any>] = []

    public init() {}

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
