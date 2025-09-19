import Foundation

// MARK: - PathMatcherBuilder

@resultBuilder
public enum PathMatcherBuilder {
    // 빈 블록
    public static func buildBlock() -> Empty {
        Empty()
    }

    // 단일 컴포넌트
    public static func buildPartialBlock<Component: PathComponent>(
        first component: Component,
    ) -> PathMatcherCore<Component.Output> {
        component.matcher
    }

    // Expression
    public static func buildExpression<Component: PathComponent>(_ component: Component) -> Component {
        component
    }
}
