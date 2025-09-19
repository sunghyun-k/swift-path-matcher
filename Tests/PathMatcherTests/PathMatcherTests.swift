import Testing
@testable import PathMatcher

@Suite("PathMatcher Tests")
struct PathMatcherTests {
  
  @Test("Basic literal matching")
  func testLiteralMatching() {
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
  func testParameterMatching() {
    // users/:owner
    let userComps = ["users", "swiftlang"]
    let userMatcher: PathMatcher<String> = PathMatcher {
      Literal("users")
      Parameter() // owner
    }
    let userResult = userMatcher.match(userComps)
    #expect(userResult == "swiftlang", "Should capture parameter value")
  }
  
  @Test("Optional parameter matching with both parameters")
  func testOptionalParameterMatchingWithBoth() {
    // users/:owner/:repo (repo 있는 경우)
    let repoComps = ["users", "swiftlang", "swift"]
    let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
      Literal("users")
      Parameter() // owner
      OptionalParameter() // repo
    }
    let repoResult = repoMatcher.match(repoComps)
    #expect(repoResult?.0 == "swiftlang", "Should capture owner parameter")
    #expect(repoResult?.1 == "swift", "Should capture optional repo parameter")
  }
  
  @Test("Optional parameter matching without optional parameter")
  func testOptionalParameterMatchingWithoutOptional() {
    // users/:owner/:repo (repo 없는 경우)
    let userComps = ["users", "swiftlang"]
    let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
      Literal("users")
      Parameter() // owner
      OptionalParameter() // repo
    }
    let repoResult = repoMatcher.match(userComps)
    #expect(repoResult?.0 == "swiftlang", "Should capture owner parameter")
    #expect(repoResult?.1 == nil, "Optional repo parameter should be nil")
  }
  
  @Test("Multiple optional parameters - all present")
  func testMultipleOptionalParametersAllPresent() {
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
  func testMultipleOptionalParametersPartial() {
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
  func testMultipleOptionalParametersSingle() {
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
  func testMultipleOptionalParametersNone() {
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
  func testNonMatchingPaths() {
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
  func testEmptyPathMatching() {
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
  func testComplexPathMatching() {
    // Simpler path: users/:userId/repos
    let complexMatcher: PathMatcher<String> = PathMatcher {
      Literal("users")
      Parameter() // userId
      Literal("repos")
    }
    
    let complexComps = ["users", "123", "repos"]
    let complexResult = complexMatcher.match(complexComps)
    #expect(complexResult == "123", "Should capture userId parameter")
  }
  
  @Test("Real world example - GitHub style paths")
  func testGitHubStylePaths() {
    // users/:owner (GitHub user profile)
    let userComps = ["users", "swiftlang"]
    let userMatcher: PathMatcher<String> = PathMatcher {
      Literal("users")
      Parameter() // owner
    }
    let userResult = userMatcher.match(userComps)
    #expect(userResult == "swiftlang", "Should capture 'swiftlang' as owner")
    
    // users/:owner/:repo (GitHub repository)
    let repoComps = ["users", "swiftlang", "swift"]
    let repoMatcher: PathMatcher<(String, String?)> = PathMatcher {
      Literal("users")
      Parameter() // owner
      OptionalParameter() // repo
    }
    let repoResult = repoMatcher.match(repoComps)
    #expect(repoResult?.0 == "swiftlang", "Should capture 'swiftlang' as owner")
    #expect(repoResult?.1 == "swift", "Should capture 'swift' as repo")
    
    // users/:owner without repo
    let userOnlyResult = repoMatcher.match(userComps)
    #expect(userOnlyResult?.0 == "swiftlang", "Should capture 'swiftlang' as owner")
    #expect(userOnlyResult?.1 == nil, "Repo should be nil when not provided")
  }
}