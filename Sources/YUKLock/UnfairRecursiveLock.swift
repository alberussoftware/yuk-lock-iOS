//
//  RecursiveLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

import Darwin

#if canImport(DarwinPrivate)

@_implementationOnly import DarwinPrivate

// MARK: -
public final class UnfairRecursiveLock: Locking {
  
  // MARK: Internal Props
  @usableFromInline
  internal let _lock: os_unfair_recursive_lock_t
  
  // MARK: Public Methods
  @inlinable
  public func lock() {
    os_unfair_recursive_lock_lock(_lock)
  }
  
  @inlinable
  public func unlock() {
    os_unfair_recursive_lock_unlock(_lock)
  }
  //
  @inlinable
  public func locked() -> Bool {
    return os_unfair_recursive_lock_trylock(_lock)
  }
  
  // MARK: Public Inits
  public init() {
    _lock = .allocate(capacity: 1)
    _lock.initialize(to: os_unfair_recursive_lock_s())
  }
  
  deinit {
    _lock.deinitialize(count: 1)
    _lock.deallocate()
  }
}

@usableFromInline
internal typealias os_unfair_recursive_lock_t = UnsafeMutablePointer<os_unfair_recursive_lock_s>

#else

// MARK: -
public final class UnfairRecursiveLock: Locking {

  // MARK: Internal Props
  @usableFromInline
  internal let _lock: pthread_mutex_s

  // MARK: Public Methods
  @inlinable
  public func lock() {
    pthread_mutex_lock(_lock)
  }

  @inlinable
  public func unlock() {
    pthread_mutex_unlock(_lock)
  }
  //
  @inlinable
  public func locked() -> Bool {
    return pthread_mutex_trylock(_lock) == 0
  }

  // MARK: Public Inits
  public init() {
    _lock = .allocate(capacity: 1)
    let attr: UnsafeMutablePointer<pthread_mutexattr_t>
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

@usableFromInline
internal typealias pthread_mutex_s = UnsafeMutablePointer<pthread_mutex_t>

#endif
