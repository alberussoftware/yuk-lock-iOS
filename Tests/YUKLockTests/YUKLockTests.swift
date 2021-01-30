import XCTest
@testable import YUKLock

// MARK: -
final class YUKLockTests: XCTestCase {
  // MARK: Private Props
  private var lock: UnfairLock!
  
  // MARK: Public Static Props
  static var allTests = [("testUnfairLock", testLockUnlock),
                         ("testSync", testSync),
                         ("testLocked", testLocked),
                         ("testTrySync", testTrySync),
                         ("testPrecondition", testPrecondition)]
  
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
    lock.precondition(.onThreadOwner)
    lock.unlock()
    lock.precondition(.notOnThreadOwner)
  }
  //
  override func tearDown() {
    lock = nil
    super.tearDown()
  }
  
}

extension YUKLockTests {
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
