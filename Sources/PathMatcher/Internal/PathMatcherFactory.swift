import Foundation

// MARK: - PathMatcherFactory (Internal)

enum PathMatcherFactory {
    static func concatenate<Output1, Output2>(
        _ first: PathMatcherCore<Output1>, _ second: PathMatcherCore<Output2>,
    )
        -> PathMatcherCore<(Output1, Output2)>
    {
        PathMatcherCore { components, index in
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
    static func concatenate<Output>(_ first: PathMatcherCore<Void>, _ second: PathMatcherCore<Output>)
        -> PathMatcherCore<
            Output
        >
    {
        PathMatcherCore { components, index in
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

    static func concatenate<Output>(_ first: PathMatcherCore<Output>, _ second: PathMatcherCore<Void>)
        -> PathMatcherCore<
            Output
        >
    {
        PathMatcherCore { components, index in
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

    static func concatenate(_ first: PathMatcherCore<Void>, _ second: PathMatcherCore<Void>)
        -> PathMatcherCore<Void>
    {
        PathMatcherCore { components, index in
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
        _ first: PathMatcherCore<(T1, T2)>, _ second: PathMatcherCore<T3>,
    )
        -> PathMatcherCore<(T1, T2, T3)>
    {
        PathMatcherCore { components, index in
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
        _ first: PathMatcherCore<(T1, T2, T3)>, _ second: PathMatcherCore<T4>,
    )
        -> PathMatcherCore<(T1, T2, T3, T4)>
    {
        PathMatcherCore { components, index in
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
        _ first: PathMatcherCore<(T1, T2, T3, T4)>, _ second: PathMatcherCore<T5>,
    )
        -> PathMatcherCore<(T1, T2, T3, T4, T5)>
    {
        PathMatcherCore { components, index in
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
        _ first: PathMatcherCore<(T1, T2, T3, T4, T5)>, _ second: PathMatcherCore<T6>,
    )
        -> PathMatcherCore<(T1, T2, T3, T4, T5, T6)>
    {
        PathMatcherCore { components, index in
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
