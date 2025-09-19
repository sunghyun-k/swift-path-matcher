import Foundation

// MARK: - PathComponent Protocol

public protocol PathComponent<Output> {
    associatedtype Output
    var matcher: PathMatcherCore<Output> { get }
}
