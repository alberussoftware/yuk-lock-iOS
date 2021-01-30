import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  [ testCase(YUKLockTests.allTests) ]
}
#endif
