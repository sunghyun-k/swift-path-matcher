import Foundation

// MARK: - PathMatcher

public struct PathMatcher<Output> {
    private let matcher: PathMatcherCore<Output>

    public init<Component: PathComponent>(@PathMatcherBuilder _ content: () -> Component)
        where Component.Output == Output
    {
        matcher = content().matcher
    }

    public func match(_ components: [String]) -> Output? {
        var index = components.startIndex
        return matcher.match(components, &index).flatMap { result in
            // 전체 컴포넌트를 매칭했는지 확인
            index == components.endIndex ? result : nil
        }
    }
}
