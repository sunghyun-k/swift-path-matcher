import Foundation
import PathMatcher

public struct PathRouter {
    private var handlers: [Handler<Any>] = []

    public init() {}

    public mutating func append<Output>(
        @PathMatcherBuilder content: () -> PathMatcher<Output>,
        handler: @escaping (URL, Output) -> Void,
    ) {
        handlers.append(Handler<Any>(
            matcher: content().match(_:),
            handler: { url, output in
                handler(url, output as! Output)
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
