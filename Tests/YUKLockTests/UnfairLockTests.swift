//
//  UnfairLockTests.swift
//  YUKLockTests
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

import XCTest
@testable import YUKLock

// MARK: -
final class UnfairLockTests: XCTestCase {
  // MARK: Private Props
  private var lock: UnfairLock!
  
  // MARK: Public Static Props
  static var allTests = [("testLockUnlock", testLockUnlock),
                         ("testSync", testSync),
                         ("testLocked", testLocked),
                         ("testTrySync", testTrySync)]
  
  // MARK: Public Methods
  override func setUp() {
    super.setUp()
    lock = UnfairLock()
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
    XCTAssertFalse(lock.locked())
    lock.unlock()
    
    XCTAssertTrue(lock.locked())
    lock.unlock()
  }
  func testTrySync() {
    lock.lock()
    XCTAssertNil(lock.trySync({ }))
    lock.unlock()
    XCTAssertNotNil(lock.trySync({ }))
  }
  //
  override func tearDown() {
    lock = nil
    super.tearDown()
  }
}
