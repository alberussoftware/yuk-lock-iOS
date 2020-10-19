import XCTest
@testable import YUKLock

final class YUKLockTests: XCTestCase {
  // MARK:
  private var lock: UnfairLock!
  
  // MARK:
  private func executeLockTest(performBlock: @escaping (_ block: () -> Void) -> Void) {
    let dispatchBlockCount = 16
    let iterationCountPerBlock = 100_000
    let queues: [DispatchQueue] = [
      .global(qos: .userInteractive),
      .global(),
      .global(qos: .utility),
    ]
    var value = 0
    
    
    let group = DispatchGroup()
    
    for block in 0..<dispatchBlockCount {
      group.enter()
      let queue = queues[block % queues.count]
      queue.async {
        for _ in 0..<iterationCountPerBlock {
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
  
  // MARK: - API
  // MARK:
  override func setUp() {
    super.setUp()
    lock = UnfairLock()
  }
  
  // MARK:
  func testLockUnlock() {
    executeLockTest { (block) in
      self.lock.lock()
      block()
      self.lock.unlock()
    }
  }
  
  func testSync() {
    executeLockTest { (block) in
      self.lock.sync { block() }
    }
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
    XCTAssertNil(lock.trySync({}))
    lock.unlock()
    XCTAssertNotNil(lock.trySync({}))
  }
  
  func testPrecondition() {
    lock.lock()
    lock.precondition(condition: .onThreadOwner)
    lock.unlock()
    lock.precondition(condition: .notOnThreadOwner)
  }
  
  // MARK:
  override func tearDown() {
    lock = nil
    super.tearDown()
  }
  
  // MARK:
  static var allTests = [
    ("testUnfairLock", testLockUnlock),
    ("testSync", testSync),
    ("testLocked", testLocked),
    ("testTrySync", testTrySync),
    ("testPrecondition", testPrecondition),
  ] 
}
