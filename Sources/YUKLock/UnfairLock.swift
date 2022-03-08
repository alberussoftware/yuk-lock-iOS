//
//  UnfairLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 10/19/20.
//

import Darwin

// MARK: -
public final class UnfairLock: Locking {
  
  // MARK: Internal Props
  @usableFromInline
  internal let _lock: os_unfair_lock_t
  
  // MARK: Public Methods
  @inlinable
  public func lock() {
    os_unfair_lock_lock(_lock)
  }
  
  @inlinable
  public func unlock() {
    os_unfair_lock_unlock(_lock)
  }
  //
  @inlinable
  public func locked() -> Bool {
    return os_unfair_lock_trylock(_lock)
  }
  
  // MARK: Public Inits
  public init() {
    _lock = .allocate(capacity: 1)
    _lock.initialize(to: os_unfair_lock_s())
  }
  
  deinit {
    _lock.deinitialize(count: 1)
    _lock.deallocate()
  }
}
