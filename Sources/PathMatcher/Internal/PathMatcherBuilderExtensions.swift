import Foundation

// MARK: - Builder Extensions

extension PathMatcherBuilder {
    // Void + Void -> Void
    public static func buildPartialBlock(
        accumulated: PathMatcherCore<Void>,
        next: PathMatcherCore<Void>,
    ) -> PathMatcherCore<Void> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // Void + T -> T
    public static func buildPartialBlock<T>(
        accumulated: PathMatcherCore<Void>,
        next: PathMatcherCore<T>,
    ) -> PathMatcherCore<T> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // T + Void -> T
    public static func buildPartialBlock<T>(
        accumulated: PathMatcherCore<T>,
        next: PathMatcherCore<Void>,
    ) -> PathMatcherCore<T> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // T1 + T2 -> (T1, T2)
    public static func buildPartialBlock<T1, T2>(
        accumulated: PathMatcherCore<T1>,
        next: PathMatcherCore<T2>,
    ) -> PathMatcherCore<(T1, T2)> {
        PathMatcherFactory.concatenate(accumulated, next)
    }

    // Component -> PathMatcherCore 변환을 위한 buildPartialBlock
    public static func buildPartialBlock<C: PathComponent>(
        accumulated: PathMatcherCore<Void>,
        next: C,
    ) -> PathMatcherCore<C.Output> where C.Output == Void {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }

    public static func buildPartialBlock<C: PathComponent>(
        accumulated: PathMatcherCore<Void>,
        next: C,
    ) -> PathMatcherCore<C.Output> {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }

    @_disfavoredOverload
    public static func buildPartialBlock<T, C: PathComponent>(
        accumulated: PathMatcherCore<T>,
        next: C,
    ) -> PathMatcherCore<(T, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }

    public static func buildPartialBlock<T, C: PathComponent>(
        accumulated: PathMatcherCore<T>,
        next: C,
    ) -> PathMatcherCore<T> where C.Output == Void {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }

    public static func buildPartialBlock<T1, T2, C: PathComponent>(
        accumulated: PathMatcherCore<(T1, T2)>,
        next: C,
    ) -> PathMatcherCore<(T1, T2, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }

    public static func buildPartialBlock<T1, T2, T3, C: PathComponent>(
        accumulated: PathMatcherCore<(T1, T2, T3)>,
        next: C,
    ) -> PathMatcherCore<(T1, T2, T3, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }

    public static func buildPartialBlock<T1, T2, T3, T4, C: PathComponent>(
        accumulated: PathMatcherCore<(T1, T2, T3, T4)>,
        next: C,
    ) -> PathMatcherCore<(T1, T2, T3, T4, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }

    public static func buildPartialBlock<T1, T2, T3, T4, T5, C: PathComponent>(
        accumulated: PathMatcherCore<(T1, T2, T3, T4, T5)>,
        next: C,
    ) -> PathMatcherCore<(T1, T2, T3, T4, T5, C.Output)> {
        PathMatcherFactory.concatenate(accumulated, next.matcher)
    }
}
