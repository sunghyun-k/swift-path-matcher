@testable import PathMatcher
import Testing

@Suite("PathMatcher Tests")
struct PathMatcherTests {
    // MARK: - Literal Matching

    @Suite("Literal Matching")
    struct LiteralMatchingTests {
        @Test("Basic literal matching")
        func basicMatching() {
            let searchMatcher = PathMatcher {
                Literal("search")
            }

            #expect(searchMatcher.match(["search"]) != nil)
            #expect(searchMatcher.match(["profile"]) == nil)

            let profileMatcher = PathMatcher {
                Literal("profile")
            }

            #expect(profileMatcher.match(["profile"]) != nil)
            #expect(profileMatcher.match(["search"]) == nil)
        }

        @Test("Case sensitive matching (default)")
        func caseSensitiveMatching() {
            let matcher = PathMatcher {
                Literal("search")
            }

            #expect(matcher.match(["search"]) != nil)
            #expect(matcher.match(["Search"]) == nil)
            #expect(matcher.match(["SEARCH"]) == nil)
        }

        @Test(
            "Case insensitive matching",
            arguments: [
                ["search"],
                ["Search"],
                ["SEARCH"],
                ["SeArCh"],
            ],
        )
        func caseInsensitiveMatching(components: [String]) {
            let matcher = PathMatcher {
                Literal("search", caseInsensitive: true)
            }

            #expect(matcher.match(components) != nil)
        }

        @Test("Case insensitive should not match different words")
        func caseInsensitiveDifferentWords() {
            let matcher = PathMatcher {
                Literal("search", caseInsensitive: true)
            }

            #expect(matcher.match(["profile"]) == nil)
        }

        @Test(
            "Complex case insensitive matching",
            arguments: [
                ["api", "v1", "users"],
                ["API", "V1", "users"],
                ["Api", "v1", "users"],
                ["api", "V1", "users"],
                ["API", "v1", "users"],
            ],
        )
        func complexCaseInsensitiveMatching(components: [String]) {
            let matcher = PathMatcher {
                Literal("api", caseInsensitive: true)
                Literal("v1", caseInsensitive: true)
                Parameter()
            }

            let result = matcher.match(components)
            #expect(result == "users")
        }

        @Test("Case insensitive should not match wrong literals")
        func caseInsensitiveWrongLiteral() {
            let matcher = PathMatcher {
                Literal("api", caseInsensitive: true)
                Literal("v1", caseInsensitive: true)
                Parameter()
            }

            #expect(matcher.match(["wrong", "v1", "users"]) == nil)
        }

        @Test("Multi-segment literal matching")
        func multiSegmentLiteral() {
            let matcher = PathMatcher {
                Literal("api/v2/books")
            }

            #expect(matcher.match(["api", "v2", "books"]) != nil)
            #expect(matcher.match(["api", "v2"]) == nil)
            #expect(matcher.match(["api", "v2", "books", "extra"]) == nil)
            #expect(matcher.match(["api", "v1", "books"]) == nil)
        }

        @Test("Multi-segment literal with parameter")
        func multiSegmentLiteralWithParameter() {
            let matcher = PathMatcher {
                Literal("api/v2/books")
                Parameter()
            }

            let result = matcher.match(["api", "v2", "books", "123"])
            #expect(result == "123")
            #expect(matcher.match(["api", "v2", "books"]) == nil)
        }

        @Test("Multi-segment literal case insensitive")
        func multiSegmentLiteralCaseInsensitive() {
            let matcher = PathMatcher {
                Literal("API/V2/Books", caseInsensitive: true)
            }

            #expect(matcher.match(["api", "v2", "books"]) != nil)
            #expect(matcher.match(["API", "V2", "BOOKS"]) != nil)
            #expect(matcher.match(["Api", "V2", "Books"]) != nil)
        }

        @Test("Multi-segment literal with leading/trailing slashes")
        func multiSegmentLiteralEdgeCases() {
            let matcher1 = PathMatcher {
                Literal("/api/v2/")
            }
            #expect(matcher1.match(["api", "v2"]) != nil)

            let matcher2 = PathMatcher {
                Literal("///api///v2///")
            }
            #expect(matcher2.match(["api", "v2"]) != nil)
        }

        @Test("Mixed single and multi-segment literals")
        func mixedLiterals() {
            let matcher = PathMatcher {
                Literal("api/v2")
                Literal("users")
                Parameter()
            }

            let result = matcher.match(["api", "v2", "users", "john"])
            #expect(result == "john")
        }
    }

    // MARK: - Parameter Matching

    @Suite("Parameter Matching")
    struct ParameterMatchingTests {
        @Test("Single parameter matching")
        func singleParameter() {
            let matcher = PathMatcher {
                Literal("owners")
                Parameter()
            }

            let result = matcher.match(["owners", "swiftlang"])
            #expect(result == "swiftlang")
        }

        @Test("Optional parameter with value present")
        func optionalParameterPresent() {
            let matcher = PathMatcher {
                Literal("owners")
                Parameter()
                OptionalParameter()
            }

            let result = matcher.match(["owners", "swiftlang", "swift"])
            #expect(result?.0 == "swiftlang")
            #expect(result?.1 == "swift")
        }

        @Test("Optional parameter with value absent")
        func optionalParameterAbsent() {
            let matcher = PathMatcher {
                Literal("owners")
                Parameter()
                OptionalParameter()
            }

            let result = matcher.match(["owners", "swiftlang"])
            #expect(result?.0 == "swiftlang")
            #expect(result?.1 == nil)
        }

        @Test("Multiple optional parameters")
        func multipleOptionalParameters() {
            let matcher = PathMatcher {
                Literal("api")
                Literal("v1")
                OptionalParameter()
                OptionalParameter()
                OptionalParameter()
            }

            // All parameters present
            let allPresent = matcher.match(["api", "v1", "users", "123", "edit"])
            #expect(allPresent?.0 == "users")
            #expect(allPresent?.1 == "123")
            #expect(allPresent?.2 == "edit")

            // Partial parameters
            let partial = matcher.match(["api", "v1", "users", "123"])
            #expect(partial?.0 == "users")
            #expect(partial?.1 == "123")
            #expect(partial?.2 == nil)

            // Single parameter
            let single = matcher.match(["api", "v1", "users"])
            #expect(single?.0 == "users")
            #expect(single?.1 == nil)
            #expect(single?.2 == nil)

            // No parameters
            let none = matcher.match(["api", "v1"])
            #expect(none?.0 == nil)
            #expect(none?.1 == nil)
            #expect(none?.2 == nil)
        }

        @Test("Complex path with mixed components")
        func complexPath() {
            let matcher = PathMatcher {
                Literal("owners")
                Parameter()
                Literal("repos")
            }

            let result = matcher.match(["owners", "123", "repos"])
            #expect(result == "123")
        }
    }

    // MARK: - Non-matching Paths

    @Suite("Non-matching Paths")
    struct NonMatchingTests {
        @Test("Too many components")
        func tooManyComponents() {
            let matcher = PathMatcher {
                Literal("search")
            }

            #expect(matcher.match(["search", "extra"]) == nil)
        }

        @Test("Too few components")
        func tooFewComponents() {
            let matcher = PathMatcher {
                Literal("search")
            }

            #expect(matcher.match([]) == nil)
        }

        @Test("Wrong component")
        func wrongComponent() {
            let matcher = PathMatcher {
                Literal("search")
            }

            #expect(matcher.match(["profile"]) == nil)
        }
    }

    // MARK: - Empty Path Matching

    @Suite("Empty Path Matching")
    struct EmptyPathTests {
        @Test("Empty matcher matches empty path")
        func emptyMatcherEmptyPath() {
            let matcher = PathMatcher {}

            #expect(matcher.match([]) != nil)
        }

        @Test("Empty matcher does not match non-empty path")
        func emptyMatcherNonEmptyPath() {
            let matcher = PathMatcher {}

            #expect(matcher.match(["something"]) == nil)
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {
        @Test("Empty string component")
        func emptyStringComponent() {
            let matcher = PathMatcher {
                Literal("search")
            }

            #expect(matcher.match([""]) == nil)
            #expect(matcher.match(["", "search"]) == nil)
        }

        @Test("Special characters in path")
        func specialCharacters() {
            let matcher = PathMatcher {
                Literal("users")
                Parameter()
            }

            #expect(matcher.match(["users", "user%20name"]) == "user%20name")
            #expect(matcher.match(["users", "user@example.com"]) == "user@example.com")
            #expect(matcher.match(["users", "user+tag"]) == "user+tag")
        }

        @Test("Unicode characters in path")
        func unicodeCharacters() {
            let matcher = PathMatcher {
                Literal("users")
                Parameter()
            }

            #expect(matcher.match(["users", "사용자"]) == "사용자")
            #expect(matcher.match(["users", "ユーザー"]) == "ユーザー")
            #expect(matcher.match(["users", "🚀"]) == "🚀")
        }

        @Test("Unicode literal matching")
        func unicodeLiteral() {
            let matcher = PathMatcher {
                Literal("사용자")
            }

            #expect(matcher.match(["사용자"]) != nil)
            #expect(matcher.match(["users"]) == nil)
        }

        @Test("Long path matching")
        func longPath() {
            let matcher = PathMatcher {
                Literal("a")
                Literal("b")
                Literal("c")
                Literal("d")
                Parameter()
            }

            let result = matcher.match(["a", "b", "c", "d", "value"])
            #expect(result == "value")
        }
    }

    // MARK: - Real World Examples

    @Suite("Real World Examples")
    struct RealWorldTests {
        @Test("GitHub style owner path")
        func gitHubOwnerPath() {
            let matcher = PathMatcher {
                Literal("owners")
                Parameter()
            }

            #expect(matcher.match(["owners", "swiftlang"]) == "swiftlang")
        }

        @Test("GitHub style repository path")
        func gitHubRepositoryPath() {
            let matcher = PathMatcher {
                Literal("owners")
                Parameter()
                OptionalParameter()
            }

            let withRepo = matcher.match(["owners", "swiftlang", "swift"])
            #expect(withRepo?.0 == "swiftlang")
            #expect(withRepo?.1 == "swift")

            let withoutRepo = matcher.match(["owners", "swiftlang"])
            #expect(withoutRepo?.0 == "swiftlang")
            #expect(withoutRepo?.1 == nil)
        }
    }
}
