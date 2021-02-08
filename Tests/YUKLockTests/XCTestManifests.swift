import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
	[ testCase(UnfairLockTests.allTests),
		testcase(RecursiveLockTests.allTests) ]
}
#endif
