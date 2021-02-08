//
//  RecursiveLockTests.swift
//  YUKLockTests
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

import XCTest
@testable import YUKLock

// MARK: -
final class RecursiveLockTests: XCTestCase {
	// MARK: Private Props
	private var lock: Locking!
	
	// MARK: Public Static Props
	static var allTests = [("testLockUnlock", testLockUnlock),
												 ("testSync", testSync),
												 ("testLocked", testLocked),
												 ("testTrySync", testTrySync)]
	
	// MARK: Public Methods
	override func setUp() {
		super.setUp()
		lock = RecursiveLock()
	}
	//
	func testLockUnlock() {
		executeLockTest { (block) in
			self.lock.lock()
			block()
			self.lock.unlock()
		}
	}
	func testSync() {
		executeLockTest { (block) in self.lock.sync { block() } }
	}
	func testLocked() {
		lock.lock()
		XCTAssertTrue(lock.locked())
		lock.unlock()
		lock.unlock()
		
		XCTAssertTrue(lock.locked())
		lock.unlock()
	}
	func testTrySync() {
		lock.lock()
		XCTAssertNotNil(lock.trySync({ }))
		lock.unlock()
		XCTAssertNotNil(lock.trySync({ }))
	}
	//
	override func tearDown() {
		lock = nil
		super.tearDown()
	}
}
