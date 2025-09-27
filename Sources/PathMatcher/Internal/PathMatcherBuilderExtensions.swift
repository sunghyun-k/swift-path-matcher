import Foundation

// MARK: - Builder Extensions

/// Extensions to the PathMatcherBuilder to handle various combinations of components.
///
/// These extensions provide the necessary overloads to properly combine different types
/// of path components while maintaining type safety and proper tuple flattening.
/// They are implementation details of the result builder system.
extension PathMatcherBuilder {
    // Void + Void -> Void
    public static func buildPartialBlock(
        accumulated: PathPattern<Void>,
        next: PathPattern<Void>,
    ) -> PathPattern<Void> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // Void + T -> T
    public static func buildPartialBlock<T>(
        accumulated: PathPattern<Void>,
        next: PathPattern<T>,
    ) -> PathPattern<T> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // T + Void -> T
    public static func buildPartialBlock<T>(
        accumulated: PathPattern<T>,
        next: PathPattern<Void>,
    ) -> PathPattern<T> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // T1 + T2 -> (T1, T2)
    public static func buildPartialBlock<T1, T2>(
        accumulated: PathPattern<T1>,
        next: PathPattern<T2>,
    ) -> PathPattern<(T1, T2)> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // Component -> PathPattern 변환을 위한 buildPartialBlock
    public static func buildPartialBlock<C: PathComponent>(
        accumulated: PathPattern<Void>,
        next: C,
    ) -> PathPattern<C.Output> where C.Output == Void {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }

    public static func buildPartialBlock<C: PathComponent>(
        accumulated: PathPattern<Void>,
        next: C,
    ) -> PathPattern<C.Output> {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }

    @_disfavoredOverload
    public static func buildPartialBlock<T, C: PathComponent>(
        accumulated: PathPattern<T>,
        next: C,
    ) -> PathPattern<(T, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }

    public static func buildPartialBlock<T, C: PathComponent>(
        accumulated: PathPattern<T>,
        next: C,
    ) -> PathPattern<T> where C.Output == Void {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }

    public static func buildPartialBlock<T1, T2, C: PathComponent>(
        accumulated: PathPattern<(T1, T2)>,
        next: C,
    ) -> PathPattern<(T1, T2, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }

    public static func buildPartialBlock<T1, T2, T3, C: PathComponent>(
        accumulated: PathPattern<(T1, T2, T3)>,
        next: C,
    ) -> PathPattern<(T1, T2, T3, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }

    public static func buildPartialBlock<T1, T2, T3, T4, C: PathComponent>(
        accumulated: PathPattern<(T1, T2, T3, T4)>,
        next: C,
    ) -> PathPattern<(T1, T2, T3, T4, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }

    public static func buildPartialBlock<T1, T2, T3, T4, T5, C: PathComponent>(
        accumulated: PathPattern<(T1, T2, T3, T4, T5)>,
        next: C,
    ) -> PathPattern<(T1, T2, T3, T4, T5, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.pattern)
    }
}
