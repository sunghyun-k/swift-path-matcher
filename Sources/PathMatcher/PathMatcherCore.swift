import Foundation

// MARK: - PathMatcherCore (Public but implementation detail)

public struct PathMatcherCore<Output> {
    let matchFunction: ([String], inout Int) -> Output?

    public init(_ matchFunction: @escaping ([String], inout Int) -> Output?) {
        self.matchFunction = matchFunction
    }

    func match(_ components: [String], _ index: inout Int) -> Output? {
        matchFunction(components, &index)
    }
}

// MARK: - PathMatcherCore as PathComponent

extension PathMatcherCore: PathComponent {
    public var matcher: PathMatcherCore<Output> { self }
}
