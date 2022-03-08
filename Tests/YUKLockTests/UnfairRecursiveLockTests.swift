//
//  UnfairRecursiveLockTests.swift
//  YUKLockTests
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

import XCTest
@testable import YUKLock

// MARK: -
internal final class UnfairRecursiveLockTests: XCTestCase {
  // MARK: Internal Static Props
  internal static var allTests = [("testLockUnlock", testLockUnlock),
                                  ("testSync", testSync),
                                  ("testLocked", testLocked),
                                  ("testTrySync", testTrySync)]
  
  // MARK: Private Props
  private var lock: Locking!
  
  // MARK: Internal Methods
  internal override func setUp() {
    super.setUp()
    lock = UnfairRecursiveLock()
  }
  //
  internal func testLockUnlock() {
    executeLockTest { (block) in
      self.lock.lock()
      block()
      self.lock.unlock()
    }
  }
  
  internal func testSync() {
    executeLockTest { (block) in self.lock.sync { block() } }
  }
  
  internal func testLocked() {
    lock.lock()
    XCTAssertTrue(lock.locked())
    lock.unlock()
    lock.unlock()
    
    XCTAssertTrue(lock.locked())
    lock.unlock()
  }
  
  internal func testTrySync() {
    lock.lock()
    XCTAssertNotNil(lock.trySync({ }))
    lock.unlock()
    XCTAssertNotNil(lock.trySync({ }))
  }
  //
  internal override func tearDown() {
    lock = nil
    super.tearDown()
  }
}
