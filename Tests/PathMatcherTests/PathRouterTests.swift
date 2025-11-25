@testable import PathMatcher
import Foundation
import Testing

@Suite("PathRouter Tests")
struct PathRouterTests {
    // MARK: - Basic Routing

    @Suite("Basic Routing")
    struct BasicRoutingTests {
        @Test("Single route matches correctly")
        func singleRouteMatches() {
            var router = PathRouter()
            var handlerCalled = false
            var receivedURL: URL?

            router.append {
                Literal("search")
            } handler: { url, _ in
                handlerCalled = true
                receivedURL = url
            }

            let testURL = URL(string: "https://example.com/search")!
            router.handle(testURL)

            #expect(handlerCalled)
            #expect(receivedURL == testURL)
        }

        @Test("Non-matching route does not call handler")
        func nonMatchingRoute() {
            var router = PathRouter()
            var handlerCalled = false

            router.append {
                Literal("search")
            } handler: { _, _ in
                handlerCalled = true
            }

            let testURL = URL(string: "https://example.com/profile")!
            router.handle(testURL)

            #expect(!handlerCalled)
        }

        @Test("Empty path matches empty pattern")
        func emptyPathMatches() {
            var router = PathRouter()
            var handlerCalled = false

            router.append {
            } handler: { _, _ in
                handlerCalled = true
            }

            let testURL = URL(string: "https://example.com/")!
            router.handle(testURL)

            #expect(handlerCalled)
        }
    }

    // MARK: - Parameter Routing

    @Suite("Parameter Routing")
    struct ParameterRoutingTests {
        @Test("Single parameter extraction")
        func singleParameter() {
            var router = PathRouter()
            var extractedUserID: String?

            router.append {
                Literal("users")
                Parameter()
            } handler: { _, userID in
                extractedUserID = userID
            }

            let testURL = URL(string: "https://example.com/users/123")!
            router.handle(testURL)

            #expect(extractedUserID == "123")
        }

        @Test("Multiple parameters extraction")
        func multipleParameters() {
            var router = PathRouter()
            var extractedUserID: String?
            var extractedPostID: String?

            router.append {
                Literal("users")
                Parameter()
                Literal("posts")
                Parameter()
            } handler: { _, params in
                let (userID, postID) = params
                extractedUserID = userID
                extractedPostID = postID
            }

            let testURL = URL(string: "https://example.com/users/john/posts/456")!
            router.handle(testURL)

            #expect(extractedUserID == "john")
            #expect(extractedPostID == "456")
        }

        @Test("Optional parameter with value present")
        func optionalParameterPresent() {
            var router = PathRouter()
            var extractedQuery: String?

            router.append {
                Literal("search")
                OptionalParameter()
            } handler: { _, query in
                extractedQuery = query
            }

            let testURL = URL(string: "https://example.com/search/swift")!
            router.handle(testURL)

            #expect(extractedQuery == "swift")
        }

        @Test("Optional parameter with value absent")
        func optionalParameterAbsent() {
            var router = PathRouter()
            var handlerCalled = false
            var extractedQuery: String?

            router.append {
                Literal("search")
                OptionalParameter()
            } handler: { _, query in
                handlerCalled = true
                extractedQuery = query
            }

            let testURL = URL(string: "https://example.com/search")!
            router.handle(testURL)

            #expect(handlerCalled)
            #expect(extractedQuery == nil)
        }
    }

    // MARK: - Multiple Routes

    @Suite("Multiple Routes")
    struct MultipleRoutesTests {
        @Test("First matching route is called")
        func firstMatchingRoute() {
            var router = PathRouter()
            var firstHandlerCalled = false
            var secondHandlerCalled = false

            router.append {
                Literal("users")
                Parameter()
            } handler: { _, _ in
                firstHandlerCalled = true
            }

            router.append {
                Literal("users")
                Parameter()
            } handler: { _, _ in
                secondHandlerCalled = true
            }

            let testURL = URL(string: "https://example.com/users/123")!
            router.handle(testURL)

            #expect(firstHandlerCalled)
            #expect(!secondHandlerCalled)
        }

        @Test("Multiple routes with different patterns")
        func multipleRoutesDifferentPatterns() {
            var router = PathRouter()
            var usersHandlerCalled = false
            var postsHandlerCalled = false
            var settingsHandlerCalled = false

            router.append {
                Literal("users")
                Parameter()
            } handler: { _, _ in
                usersHandlerCalled = true
            }

            router.append {
                Literal("posts")
                Parameter()
            } handler: { _, _ in
                postsHandlerCalled = true
            }

            router.append {
                Literal("settings")
            } handler: { _, _ in
                settingsHandlerCalled = true
            }

            // Test users route
            router.handle(URL(string: "https://example.com/users/123")!)
            #expect(usersHandlerCalled)
            #expect(!postsHandlerCalled)
            #expect(!settingsHandlerCalled)

            // Reset
            usersHandlerCalled = false

            // Test posts route
            router.handle(URL(string: "https://example.com/posts/456")!)
            #expect(!usersHandlerCalled)
            #expect(postsHandlerCalled)
            #expect(!settingsHandlerCalled)

            // Reset
            postsHandlerCalled = false

            // Test settings route
            router.handle(URL(string: "https://example.com/settings")!)
            #expect(!usersHandlerCalled)
            #expect(!postsHandlerCalled)
            #expect(settingsHandlerCalled)
        }

        @Test("Route order does not matter when path lengths differ")
        func routeOrderIndependent() {
            // Test 1: specific first, general second
            var router1 = PathRouter()
            var results1: [String] = []

            router1.append {
                Literal("api")
                Parameter()
                Literal("items")
                Parameter()
            } handler: { _, _ in
                results1.append("specific")
            }

            router1.append {
                Literal("api")
                Parameter()
            } handler: { _, _ in
                results1.append("general")
            }

            router1.handle(URL(string: "https://example.com/api/v1/items/123")!)
            router1.handle(URL(string: "https://example.com/api/v1")!)

            // Test 2: general first, specific second (reversed order)
            var router2 = PathRouter()
            var results2: [String] = []

            router2.append {
                Literal("api")
                Parameter()
            } handler: { _, _ in
                results2.append("general")
            }

            router2.append {
                Literal("api")
                Parameter()
                Literal("items")
                Parameter()
            } handler: { _, _ in
                results2.append("specific")
            }

            router2.handle(URL(string: "https://example.com/api/v1/items/123")!)
            router2.handle(URL(string: "https://example.com/api/v1")!)

            // Both should produce the same results regardless of registration order
            #expect(results1 == ["specific", "general"])
            #expect(results2 == ["specific", "general"])
        }
    }

    // MARK: - URL Handling

    @Suite("URL Handling")
    struct URLHandlingTests {
        @Test("URL with query parameters")
        func urlWithQueryParameters() {
            var router = PathRouter()
            var extractedID: String?
            var receivedURL: URL?

            router.append {
                Literal("users")
                Parameter()
            } handler: { url, id in
                extractedID = id
                receivedURL = url
            }

            let testURL = URL(string: "https://example.com/users/123?tab=profile&view=full")!
            router.handle(testURL)

            #expect(extractedID == "123")
            #expect(receivedURL?.query == "tab=profile&view=full")
        }

        @Test("URL with fragment")
        func urlWithFragment() {
            var router = PathRouter()
            var handlerCalled = false
            var receivedURL: URL?

            router.append {
                Literal("docs")
                Parameter()
            } handler: { url, _ in
                handlerCalled = true
                receivedURL = url
            }

            let testURL = URL(string: "https://example.com/docs/readme#section1")!
            router.handle(testURL)

            #expect(handlerCalled)
            #expect(receivedURL?.fragment == "section1")
        }

        @Test("Different URL schemes")
        func differentSchemes() {
            var router = PathRouter()
            var handlerCallCount = 0

            router.append {
                Literal("app")
                Literal("open")
            } handler: { _, _ in
                handlerCallCount += 1
            }

            // HTTP scheme
            router.handle(URL(string: "http://example.com/app/open")!)
            #expect(handlerCallCount == 1)

            // HTTPS scheme
            router.handle(URL(string: "https://example.com/app/open")!)
            #expect(handlerCallCount == 2)
        }

        @Test("Custom URL scheme")
        func customScheme() {
            var router = PathRouter()
            var handlerCalled = false

            // Note: In custom schemes like "myapp://host/path",
            // the first component after scheme becomes the host, not a path component.
            router.append {
                Literal("open")
            } handler: { _, _ in
                handlerCalled = true
            }

            // myapp://app/open -> host="app", path="/open"
            router.handle(URL(string: "myapp://app/open")!)
            #expect(handlerCalled)
        }
    }

    // MARK: - Real World Scenarios (Based on Example App)

    @Suite("Real World Scenarios")
    struct RealWorldScenariosTests {
        @Test("Complete app routing scenario")
        func completeAppRouting() {
            var router = PathRouter()
            var routes: [String] = []

            router.append {
                Literal("users")
                Parameter()
            } handler: { _, userID in
                routes.append("user:\(userID)")
            }

            router.append {
                Literal("users")
                Parameter()
                Literal("posts")
                Parameter()
            } handler: { _, params in
                let (userID, postID) = params
                routes.append("post:\(userID)/\(postID)")
            }

            router.append {
                Literal("settings")
            } handler: { _, _ in
                routes.append("settings")
            }

            router.append {
                Literal("search")
                OptionalParameter()
            } handler: { _, query in
                routes.append("search:\(query ?? "none")")
            }

            // Test all routes
            router.handle(URL(string: "https://example.com/users/alice")!)
            router.handle(URL(string: "https://example.com/users/alice/posts/post-123")!)
            router.handle(URL(string: "https://example.com/settings")!)
            router.handle(URL(string: "https://example.com/search/swift")!)
            router.handle(URL(string: "https://example.com/search")!)

            #expect(routes == [
                "user:alice",
                "post:alice/post-123",
                "settings",
                "search:swift",
                "search:none",
            ])
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {
        @Test("URL percent-encoding is decoded by Foundation")
        func encodedCharacters() {
            var router = PathRouter()
            var extractedValue: String?

            router.append {
                Literal("search")
                Parameter()
            } handler: { _, value in
                extractedValue = value
            }

            let testURL = URL(string: "https://example.com/search/hello%20world")!
            router.handle(testURL)

            // URL.pathComponents automatically decodes percent-encoded values
            #expect(extractedValue == "hello world")
        }

        @Test("No routes registered does not crash")
        func noRoutesRegistered() {
            let router = PathRouter()
            router.handle(URL(string: "https://example.com/anything")!)
        }

        @Test("No matching route does not crash")
        func noMatchingRoute() {
            var router = PathRouter()
            var handlerCalled = false

            router.append {
                Literal("users")
            } handler: { _, _ in
                handlerCalled = true
            }

            router.handle(URL(string: "https://example.com/posts")!)
            #expect(!handlerCalled)
        }
    }
}
