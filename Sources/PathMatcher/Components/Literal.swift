import Foundation

// MARK: - Literal Component
public struct Literal: PathComponent {
  public typealias Output = Void
  private let value: String

  public init(_ value: String) {
    self.value = value
  }

  public var matcher: PathMatcherCore<Void> {
    PathMatcherCore { components, index in
      guard index < components.endIndex, components[index] == value else {
        return nil
      }
      index += 1
      return ()
    }
  }
}