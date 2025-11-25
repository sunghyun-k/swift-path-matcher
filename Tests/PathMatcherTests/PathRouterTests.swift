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

        @Test("More specific route before general route")
        func specificBeforeGeneral() {
            var router = PathRouter()
            var specificHandlerCalled = false
            var generalHandlerCalled = false

            // More specific route first
            router.append {
                Literal("users")
                Parameter()
                Literal("posts")
                Parameter()
            } handler: { _, _ in
                specificHandlerCalled = true
            }

            // General route second
            router.append {
                Literal("users")
                Parameter()
            } handler: { _, _ in
                generalHandlerCalled = true
            }

            // Should match specific route
            router.handle(URL(string: "https://example.com/users/john/posts/123")!)
            #expect(specificHandlerCalled)
            #expect(!generalHandlerCalled)

            // Reset
            specificHandlerCalled = false

            // Should match general route
            router.handle(URL(string: "https://example.com/users/john")!)
            #expect(!specificHandlerCalled)
            #expect(generalHandlerCalled)
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
        @Test("User profile route")
        func userProfileRoute() {
            var router = PathRouter()
            var userID: String?

            router.append {
                Literal("users")
                Parameter()
            } handler: { _, id in
                userID = id
            }

            router.handle(URL(string: "https://example.com/users/alice")!)
            #expect(userID == "alice")
        }

        @Test("User post route")
        func userPostRoute() {
            var router = PathRouter()
            var userID: String?
            var postID: String?

            router.append {
                Literal("users")
                Parameter()
                Literal("posts")
                Parameter()
            } handler: { _, params in
                (userID, postID) = params
            }

            router.handle(URL(string: "https://example.com/users/alice/posts/post-123")!)
            #expect(userID == "alice")
            #expect(postID == "post-123")
        }

        @Test("Settings route")
        func settingsRoute() {
            var router = PathRouter()
            var handlerCalled = false

            router.append {
                Literal("settings")
            } handler: { _, _ in
                handlerCalled = true
            }

            router.handle(URL(string: "https://example.com/settings")!)
            #expect(handlerCalled)
        }

        @Test("Search route with optional query")
        func searchRoute() {
            var router = PathRouter()
            var query: String?
            var handlerCallCount = 0

            router.append {
                Literal("search")
                OptionalParameter()
            } handler: { _, q in
                query = q
                handlerCallCount += 1
            }

            // With search query
            router.handle(URL(string: "https://example.com/search/swift")!)
            #expect(query == "swift")
            #expect(handlerCallCount == 1)

            // Without search query
            router.handle(URL(string: "https://example.com/search")!)
            #expect(query == nil)
            #expect(handlerCallCount == 2)
        }

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
            router.handle(URL(string: "https://example.com/settings")!)
            router.handle(URL(string: "https://example.com/search/swift")!)
            router.handle(URL(string: "https://example.com/search")!)

            #expect(routes == ["user:alice", "settings", "search:swift", "search:none"])
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {
        @Test("URL with encoded characters")
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

            // URL automatically decodes percent-encoded values in pathComponents
            #expect(extractedValue == "hello world")
        }

        @Test("Unicode in path")
        func unicodePath() {
            var router = PathRouter()
            var extractedValue: String?

            router.append {
                Literal("users")
                Parameter()
            } handler: { _, value in
                extractedValue = value
            }

            let testURL = URL(string: "https://example.com/users/사용자")!
            router.handle(testURL)

            #expect(extractedValue == "사용자")
        }

        @Test("Multi-segment literal routing")
        func multiSegmentLiteral() {
            var router = PathRouter()
            var extractedID: String?

            router.append {
                Literal("api/v2/users")
                Parameter()
            } handler: { _, id in
                extractedID = id
            }

            let testURL = URL(string: "https://example.com/api/v2/users/123")!
            router.handle(testURL)

            #expect(extractedID == "123")
        }

        @Test("Case insensitive routing")
        func caseInsensitiveRouting() {
            var router = PathRouter()
            var handlerCallCount = 0

            router.append {
                Literal("API", caseInsensitive: true)
                Literal("Users", caseInsensitive: true)
                Parameter()
            } handler: { _, _ in
                handlerCallCount += 1
            }

            router.handle(URL(string: "https://example.com/api/users/123")!)
            router.handle(URL(string: "https://example.com/API/USERS/456")!)
            router.handle(URL(string: "https://example.com/Api/Users/789")!)

            #expect(handlerCallCount == 3)
        }

        @Test("No routes registered")
        func noRoutesRegistered() {
            let router = PathRouter()
            // Should not crash
            router.handle(URL(string: "https://example.com/anything")!)
        }

        @Test("URL with only scheme and host")
        func urlWithOnlySchemeAndHost() {
            var router = PathRouter()
            var handlerCalled = false

            router.append {
            } handler: { _, _ in
                handlerCalled = true
            }

            let testURL = URL(string: "https://example.com")!
            router.handle(testURL)

            #expect(handlerCalled)
        }
    }
}
