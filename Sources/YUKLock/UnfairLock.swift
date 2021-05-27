//
//  UnfairLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 10/19/20.
//

import Darwin.os.lock

// MARK: -
public final class UnfairLock: Locking {
  // MARK: Internal Props
  @usableFromInline internal let unfairLock: os_unfair_lock_t
  
  // MARK: Public Methods
  @inlinable public func lock() {
    os_unfair_lock_lock(unfairLock)
  }
  @inlinable public func unlock() {
    os_unfair_lock_unlock(unfairLock)
  }
  //
  @inlinable public func locked() -> Bool {
    os_unfair_lock_trylock(unfairLock)
  }
  
  // MARK: Public Inits
  public init() {
    unfairLock = .allocate(capacity: 1)
    unfairLock.initialize(to: .init())
  }
  deinit {
    unfairLock.deinitialize(count: 1)
    unfairLock.deallocate()
  }
}
