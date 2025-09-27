@testable import PathMatcher
import Testing

@Suite("PathMatcher Tests")
struct PathMatcherTests {
    @Test("Basic literal matching")
    func literalMatching() {
        // search
        let searchComps = ["search"]
        let searchMatcher: PathMatcher<Void> = PathMatcher {
            Literal("search")
        }
        let searchResult = searchMatcher.match(searchComps)
        #expect(searchResult != nil, "Search should match")

        // profile (correct matching)
        let profileComps = ["profile"]
        let profileMatcher: PathMatcher<Void> = PathMatcher {
            Literal("profile")
        }
        let profileResult = profileMatcher.match(profileComps)
        #expect(profileResult != nil, "Profile should match with correct components")

        // profile (wrong matching test)
        let profileWrongResult = profileMatcher.match(searchComps)
        #expect(profileWrongResult == nil, "Profile should not match with search components")
    }

    @Test("Parameter matching")
    func parameterMatching() {
        // owners/:owner
        let ownerComps = ["owners", "swiftlang"]
        let ownerMatcher: PathMatcher<String> = PathMatcher {
            Literal("owners")
            Parameter() // owner
        }
        let ownerResult = ownerMatcher.match(ownerComps)
        #expect(ownerResult == "swiftlang", "Should capture parameter value")
    }

    @Test("Optional parameter matching with both parameters")
    func optionalParameterMatchingWithBoth() {
        // owners/:owner/:repo (repo 있는 경우)
        let repoComps = ["owners", "swiftlang", "swift"]
        let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
            Literal("owners")
            Parameter() // owner
            OptionalParameter() // repo
        }
        let repoResult = repoMatcher.match(repoComps)
        #expect(repoResult?.0 == "swiftlang", "Should capture owner parameter")
        #expect(repoResult?.1 == "swift", "Should capture optional repo parameter")
    }

    @Test("Optional parameter matching without optional parameter")
    func optionalParameterMatchingWithoutOptional() {
        // owners/:owner/:repo (repo 없는 경우)
        let ownerComps = ["owners", "swiftlang"]
        let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
            Literal("owners")
            Parameter() // owner
            OptionalParameter() // repo
        }
        let repoResult = repoMatcher.match(ownerComps)
        #expect(repoResult?.0 == "swiftlang", "Should capture owner parameter")
        #expect(repoResult?.1 == nil, "Optional repo parameter should be nil")
    }

    @Test("Multiple optional parameters - all present")
    func multipleOptionalParametersAllPresent() {
        // api/v1/:resource?/:id?/:action?
        let apiMatcher: PathMatcher<(String?, String?, String?)> = PathMatcher {
            Literal("api")
            Literal("v1")
            OptionalParameter() // resource
            OptionalParameter() // id
            OptionalParameter() // action
        }

        // 모든 파라미터가 있는 경우
        let apiComps1 = ["api", "v1", "users", "123", "edit"]
        let apiResult1 = apiMatcher.match(apiComps1)
        #expect(apiResult1?.0 == "users", "Should capture resource parameter")
        #expect(apiResult1?.1 == "123", "Should capture id parameter")
        #expect(apiResult1?.2 == "edit", "Should capture action parameter")
    }

    @Test("Multiple optional parameters - partial")
    func multipleOptionalParametersPartial() {
        let apiMatcher: PathMatcher<(String?, String?, String?)> = PathMatcher {
            Literal("api")
            Literal("v1")
            OptionalParameter() // resource
            OptionalParameter() // id
            OptionalParameter() // action
        }

        // 일부 파라미터만 있는 경우
        let apiComps2 = ["api", "v1", "users", "123"]
        let apiResult2 = apiMatcher.match(apiComps2)
        #expect(apiResult2?.0 == "users", "Should capture resource parameter")
        #expect(apiResult2?.1 == "123", "Should capture id parameter")
        #expect(apiResult2?.2 == nil, "Action parameter should be nil")
    }

    @Test("Multiple optional parameters - single")
    func multipleOptionalParametersSingle() {
        let apiMatcher: PathMatcher<(String?, String?, String?)> = PathMatcher {
            Literal("api")
            Literal("v1")
            OptionalParameter() // resource
            OptionalParameter() // id
            OptionalParameter() // action
        }

        // 하나의 파라미터만 있는 경우
        let apiComps3 = ["api", "v1", "users"]
        let apiResult3 = apiMatcher.match(apiComps3)
        #expect(apiResult3?.0 == "users", "Should capture resource parameter")
        #expect(apiResult3?.1 == nil, "Id parameter should be nil")
        #expect(apiResult3?.2 == nil, "Action parameter should be nil")
    }

    @Test("Multiple optional parameters - none")
    func multipleOptionalParametersNone() {
        let apiMatcher: PathMatcher<(String?, String?, String?)> = PathMatcher {
            Literal("api")
            Literal("v1")
            OptionalParameter() // resource
            OptionalParameter() // id
            OptionalParameter() // action
        }

        // 파라미터가 없는 경우
        let apiComps4 = ["api", "v1"]
        let apiResult4 = apiMatcher.match(apiComps4)
        #expect(apiResult4?.0 == nil, "Resource parameter should be nil")
        #expect(apiResult4?.1 == nil, "Id parameter should be nil")
        #expect(apiResult4?.2 == nil, "Action parameter should be nil")
    }

    @Test("Non-matching paths")
    func nonMatchingPaths() {
        let searchMatcher: PathMatcher<Void> = PathMatcher {
            Literal("search")
        }

        // Too many components
        let tooManyResult = searchMatcher.match(["search", "extra"])
        #expect(tooManyResult == nil, "Should not match with extra components")

        // Too few components
        let tooFewResult = searchMatcher.match([])
        #expect(tooFewResult == nil, "Should not match with no components")

        // Wrong component
        let wrongResult = searchMatcher.match(["profile"])
        #expect(wrongResult == nil, "Should not match with wrong component")
    }

    @Test("Empty path matching")
    func emptyPathMatching() {
        let emptyMatcher: PathMatcher<Void> = PathMatcher {
            // Empty matcher
        }
        let emptyResult = emptyMatcher.match([])
        #expect(emptyResult != nil, "Empty matcher should match empty path")

        // Should not match non-empty path
        let nonEmptyResult = emptyMatcher.match(["something"])
        #expect(nonEmptyResult == nil, "Empty matcher should not match non-empty path")
    }

    @Test("Complex path matching - simpler version")
    func complexPathMatching() {
        // Simpler path: owners/:ownerId/repos
        let complexMatcher: PathMatcher<String> = PathMatcher {
            Literal("owners")
            Parameter() // ownerId
            Literal("repos")
        }

        let complexComps = ["owners", "123", "repos"]
        let complexResult = complexMatcher.match(complexComps)
        #expect(complexResult == "123", "Should capture ownerId parameter")
    }

    @Test("Real world example - GitHub style paths")
    func gitHubStylePaths() {
        // owners/:owner (GitHub owner profile)
        let ownerComps = ["owners", "swiftlang"]
        let ownerMatcher: PathMatcher<String> = PathMatcher {
            Literal("owners")
            Parameter() // owner
        }
        let ownerResult = ownerMatcher.match(ownerComps)
        #expect(ownerResult == "swiftlang", "Should capture 'swiftlang' as owner")

        // owners/:owner/:repo (GitHub repository)
        let repoComps = ["owners", "swiftlang", "swift"]
        let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
            Literal("owners")
            Parameter() // owner
            OptionalParameter() // repo
        }
        let repoResult = repoMatcher.match(repoComps)
        #expect(repoResult?.0 == "swiftlang", "Should capture 'swiftlang' as owner")
        #expect(repoResult?.1 == "swift", "Should capture 'swift' as repo")

        // owners/:owner without repo
        let ownerOnlyResult = repoMatcher.match(ownerComps)
        #expect(ownerOnlyResult?.0 == "swiftlang", "Should capture 'swiftlang' as owner")
        #expect(ownerOnlyResult?.1 == nil, "Repo should be nil when not provided")
    }

    @Test("Case insensitive literal matching")
    func caseInsensitiveLiteralMatching() {
        // Case sensitive (default behavior)
        let caseSensitiveMatcher: PathMatcher<Void> = PathMatcher {
            Literal("search")
        }
        
        // Should match exact case
        let exactResult = caseSensitiveMatcher.match(["search"])
        #expect(exactResult != nil, "Should match exact case")
        
        // Should not match different case
        let upperResult = caseSensitiveMatcher.match(["Search"])
        #expect(upperResult == nil, "Should not match different case by default")
        
        let lowerResult = caseSensitiveMatcher.match(["SEARCH"])
        #expect(lowerResult == nil, "Should not match uppercase when expecting lowercase")
        
        // Case insensitive matcher
        let caseInsensitiveMatcher: PathMatcher<Void> = PathMatcher {
            Literal("search", caseInsensitive: true)
        }
        
        // Should match exact case
        let exactInsensitiveResult = caseInsensitiveMatcher.match(["search"])
        #expect(exactInsensitiveResult != nil, "Should match exact case even when case insensitive")
        
        // Should match different cases
        let upperInsensitiveResult = caseInsensitiveMatcher.match(["Search"])
        #expect(upperInsensitiveResult != nil, "Should match capitalized version")
        
        let allUpperResult = caseInsensitiveMatcher.match(["SEARCH"])
        #expect(allUpperResult != nil, "Should match uppercase version")
        
        let mixedCaseResult = caseInsensitiveMatcher.match(["SeArCh"])
        #expect(mixedCaseResult != nil, "Should match mixed case version")
        
        // Should still not match different words
        let wrongWordResult = caseInsensitiveMatcher.match(["profile"])
        #expect(wrongWordResult == nil, "Should not match different words")
    }

    @Test("Complex case insensitive matching")
    func complexCaseInsensitiveMatching() {
        // Multiple literals with case insensitive
        let apiMatcher: PathMatcher<String> = PathMatcher {
            Literal("api", caseInsensitive: true)
            Literal("v1", caseInsensitive: true)
            Parameter() // resource
        }
        
        // Test various case combinations
        let testCases = [
            ["api", "v1", "users"],
            ["API", "V1", "users"],
            ["Api", "v1", "users"],
            ["api", "V1", "users"],
            ["API", "v1", "users"]
        ]
        
        for (index, testCase) in testCases.enumerated() {
            let result = apiMatcher.match(testCase)
            #expect(result == "users", "Test case \(index + 1) should match and capture 'users'")
        }
        
        // Should not match wrong literals
        let wrongResult = apiMatcher.match(["wrong", "v1", "users"])
        #expect(wrongResult == nil, "Should not match wrong first literal")
    }
}
