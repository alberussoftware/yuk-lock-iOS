//
//  RecursiveLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

import Darwin.POSIX.pthread

// MARK: -
public final class RecursiveLock: Locking {
  // MARK: Internal Props
  @usableFromInline internal let recursiveLock: UnsafeMutablePointer<pthread_mutex_t>
  
  // MARK: Public Methods
  @inlinable public func lock() {
    pthread_mutex_lock(recursiveLock)
  }
  @inlinable public func unlock() {
    pthread_mutex_unlock(recursiveLock)
  }
  //
  @inlinable public func locked() -> Bool {
    pthread_mutex_trylock(recursiveLock) == .zero
  }
  
  // MARK: Public Inits
  public init() {
    recursiveLock = .allocate(capacity: 1)
    let attr: UnsafeMutablePointer<pthread_mutexattr_t>
    attr = .allocate(capacity: 1)
    pthread_mutexattr_init(attr)
    pthread_mutexattr_settype(attr, PTHREAD_MUTEX_RECURSIVE)
    pthread_mutex_init(recursiveLock, attr)
    pthread_mutexattr_destroy(attr)
    attr.deinitialize(count: 1)
    attr.deallocate()
  }
  deinit {
    pthread_mutex_destroy(recursiveLock)
    recursiveLock.deinitialize(count: 1)
    recursiveLock.deallocate()
  }
}
