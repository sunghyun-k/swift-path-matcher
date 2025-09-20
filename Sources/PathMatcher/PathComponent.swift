import Foundation

// MARK: - PathComponent Protocol

/// A protocol that defines a component that can be used in path matching.
///
/// Components are the building blocks of path matchers. Each component defines how to match
/// a specific part of a URL path and what value to extract from it.
///
/// ## Built-in Components
///
/// - ``Literal``: Matches exact text
/// - ``Parameter``: Captures a required path segment
/// - ``OptionalParameter``: Captures an optional path segment
///
/// ## Custom Components
///
/// You can create custom components by conforming to this protocol:
///
/// ```swift
/// struct CustomComponent: PathComponent {
///     typealias Output = String
///
///     var matcher: PathPattern<String> {
///         PathPattern { components, index in
///             // Your custom matching logic
///         }
///     }
/// }
/// ```
public protocol PathComponent<Output> {
    /// The type of value this component produces when it matches successfully.
    associatedtype Output

    /// The pattern that implements the matching logic for this component.
    var matcher: PathPattern<Output> { get }
}
