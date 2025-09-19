import Foundation

// MARK: - Empty Component (Public but implementation detail)

public struct Empty: PathComponent {
    public typealias Output = Void

    public init() {}

    public var matcher: PathMatcherCore<Void> {
        PathMatcherCore { _, _ in () }
    }
}
