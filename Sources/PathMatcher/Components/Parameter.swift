import Foundation

// MARK: - Parameter Component
public struct Parameter: PathComponent {
  public typealias Output = String

  public init() {}

  public var matcher: PathMatcherCore<String> {
    PathMatcherCore { components, index in
      guard index < components.endIndex else {
        return nil
      }
      let value = components[index]
      index += 1
      return value
    }
  }
}