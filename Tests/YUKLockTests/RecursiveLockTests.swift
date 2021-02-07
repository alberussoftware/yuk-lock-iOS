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
  private var lock: Lock!
  
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

extension RecursiveLockTests {
  private func executeLockTest(performBlock: @escaping (_ block: () -> Void) -> Void) {
    let dispatchBlockCount = 16
    let iterationCountPerBlock = 100_000
    let queues: [DispatchQueue] = [.global(qos: .userInteractive),
                                   .global(),
                                   .global(qos: .utility)]
    var value = 0
    
    let group = DispatchGroup()
    
    (0..<dispatchBlockCount).forEach {
      group.enter()
      let queue = queues[$0 % queues.count]
      queue.async {
        (0..<iterationCountPerBlock).forEach { (_) in
          performBlock {
            value += 2
            value -= 1
          }
        }
        group.leave()
      }
    }
    
    _ = group.wait(timeout: .distantFuture)
    
    XCTAssertEqual(value, dispatchBlockCount * iterationCountPerBlock)
  }
}
