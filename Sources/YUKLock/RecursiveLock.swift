//
//  RecursiveLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

import Darwin.POSIX.pthread

// MARK: -
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, macCatalyst 13.0, *)
public final class RecursiveLock: Lock {
  // MARK: Internal Props
  @usableFromInline internal private(set) var _lock: UnsafeMutablePointer<pthread_mutex_t>
  
  // MARK: Public Methods
  @inlinable public func locked() -> Bool {
    pthread_mutex_trylock(_lock) == .zero
  }
  //
  @inlinable public func lock() {
    pthread_mutex_lock(_lock)
  }
  @inlinable public func unlock() {
    pthread_mutex_unlock(_lock)
  }
  
  // MARK: Public Inits
  public init() {
    _lock = .allocate(capacity: 1)
    var attr: UnsafeMutablePointer<pthread_mutexattr_t>
    attr = .allocate(capacity: 1)
    pthread_mutexattr_init(attr)
    pthread_mutexattr_settype(attr, PTHREAD_MUTEX_RECURSIVE)
    pthread_mutex_init(_lock, attr)
    pthread_mutexattr_destroy(attr)
    attr.deinitialize(count: 1)
    attr.deallocate()
  }
  deinit {
    pthread_mutex_destroy(_lock)
    _lock.deinitialize(count: 1)
    _lock.deallocate()
  }
}
