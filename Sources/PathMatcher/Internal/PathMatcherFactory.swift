import Foundation

// MARK: - PathMatcherFactory (Internal)

/// Internal factory for combining path patterns with proper type handling.
///
/// This enum provides static methods for concatenating path patterns while handling
/// various type combinations, including void elimination and tuple flattening.
/// These methods are used by the result builder system to combine components.
enum PathMatcherFactory {
    static func concatenate<Output1, Output2>(
        _ first: PathPattern<Output1>, _ second: PathPattern<Output2>,
    )
        -> PathPattern<(Output1, Output2)>
    {
        PathPattern { components, index in
            let startIndex = index
            guard let firstResult = first.match(components, &index) else {
                index = startIndex
                return nil
            }
            guard let secondResult = second.match(components, &index) else {
                index = startIndex
                return nil
            }
            return (firstResult, secondResult)
        }
    }

    // Void를 무시하는 버전들
    static func concatenate<Output>(_ first: PathPattern<Void>, _ second: PathPattern<Output>)
        -> PathPattern<
            Output
        >
    {
        PathPattern { components, index in
            let startIndex = index
            guard first.match(components, &index) != nil else {
                index = startIndex
                return nil
            }
            guard let secondResult = second.match(components, &index) else {
                index = startIndex
                return nil
            }
            return secondResult
        }
    }

    static func concatenate<Output>(_ first: PathPattern<Output>, _ second: PathPattern<Void>)
        -> PathPattern<
            Output
        >
    {
        PathPattern { components, index in
            let startIndex = index
            guard let firstResult = first.match(components, &index) else {
                index = startIndex
                return nil
            }
            guard second.match(components, &index) != nil else {
                index = startIndex
                return nil
            }
            return firstResult
        }
    }

    static func concatenate(_ first: PathPattern<Void>, _ second: PathPattern<Void>)
        -> PathPattern<Void>
    {
        PathPattern { components, index in
            let startIndex = index
            guard first.match(components, &index) != nil else {
                index = startIndex
                return nil
            }
            guard second.match(components, &index) != nil else {
                index = startIndex
                return nil
            }
            return ()
        }
    }

    // (T1, T2) + T3 -> (T1, T2, T3) 플래튼 버전
    static func concatenate<T1, T2, T3>(
        _ first: PathPattern<(T1, T2)>, _ second: PathPattern<T3>,
    )
        -> PathPattern<(T1, T2, T3)>
    {
        PathPattern { components, index in
            let startIndex = index
            guard let firstResult = first.match(components, &index) else {
                index = startIndex
                return nil
            }
            guard let secondResult = second.match(components, &index) else {
                index = startIndex
                return nil
            }
            return (firstResult.0, firstResult.1, secondResult)
        }
    }

    // (T1, T2, T3) + T4 -> (T1, T2, T3, T4) 플래튼 버전
    static func concatenate<T1, T2, T3, T4>(
        _ first: PathPattern<(T1, T2, T3)>, _ second: PathPattern<T4>,
    )
        -> PathPattern<(T1, T2, T3, T4)>
    {
        PathPattern { components, index in
            let startIndex = index
            guard let firstResult = first.match(components, &index) else {
                index = startIndex
                return nil
            }
            guard let secondResult = second.match(components, &index) else {
                index = startIndex
                return nil
            }
            return (firstResult.0, firstResult.1, firstResult.2, secondResult)
        }
    }

    // (T1, T2, T3, T4) + T5 -> (T1, T2, T3, T4, T5) 플래튼 버전
    static func concatenate<T1, T2, T3, T4, T5>(
        _ first: PathPattern<(T1, T2, T3, T4)>, _ second: PathPattern<T5>,
    )
        -> PathPattern<(T1, T2, T3, T4, T5)>
    {
        PathPattern { components, index in
            let startIndex = index
            guard let firstResult = first.match(components, &index) else {
                index = startIndex
                return nil
            }
            guard let secondResult = second.match(components, &index) else {
                index = startIndex
                return nil
            }
            return (firstResult.0, firstResult.1, firstResult.2, firstResult.3, secondResult)
        }
    }

    // (T1, T2, T3, T4, T5) + T6 -> (T1, T2, T3, T4, T5, T6) 플래튼 버전
    static func concatenate<T1, T2, T3, T4, T5, T6>(
        _ first: PathPattern<(T1, T2, T3, T4, T5)>, _ second: PathPattern<T6>,
    )
        -> PathPattern<(T1, T2, T3, T4, T5, T6)>
    {
        PathPattern { components, index in
            let startIndex = index
            guard let firstResult = first.match(components, &index) else {
                index = startIndex
                return nil
            }
            guard let secondResult = second.match(components, &index) else {
                index = startIndex
                return nil
            }
            return (
                firstResult.0, firstResult.1, firstResult.2, firstResult.3, firstResult.4, secondResult,
            )
        }
    }
}
