import Foundation

// MARK: - OptionalParameter Component

public struct OptionalParameter: PathComponent {
    public typealias Output = String?

    public init() {}

    public var matcher: PathMatcherCore<String?> {
        PathMatcherCore { components, index in
            if index < components.endIndex {
                let value = components[index]
                index += 1
                return value
            } else {
                return nil as String?
            }
        }
    }
}
