//
//  XCTestCase+Helper.swift
//  YUKLockTests
//
//  Created by Ruslan Lutfullin on 2/9/21.
//

import XCTest

// MARK: -
extension XCTestCase {
  internal func executeLockTest(performBlock: @escaping ((_ block: () -> Void) -> Void)) {
    let dispatchBlockCount = 16
    let iterationCountPerBlock = 100_000
    let queues: [DispatchQueue] = [.global(qos: .userInteractive),
                                   .global(),
                                   .global(qos: .utility)]
    var value = 0
    
    let group = DispatchGroup()
    
    for i in 0..<dispatchBlockCount {
      group.enter()
      let queue = queues[i % queues.count]
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
}
