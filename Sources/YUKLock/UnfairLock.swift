//
//  UnfairLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 10/19/20.
//

import Darwin.os.lock

// MARK: -
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, macCatalyst 13.0, *)
public final class UnfairLock {
  // MARK: Internal Props
  @usableFromInline internal let _lock: os_unfair_lock_t
  
  // MARK: Public Methods
  @inlinable public func precondition(_ precidcate: Predicate) {
    if precidcate == .onThreadOwner {
      os_unfair_lock_assert_owner(_lock)
    }
    else {
      os_unfair_lock_assert_not_owner(_lock)
    }
  }
  //
  @inlinable public func trySync<R>(_ block: () throws -> R) rethrows -> R? {
    guard locked() else {
      return nil
    }
    defer {
      unlock()
    }
    return try block()
  }
  @inlinable public func sync<R>(_ block: () throws -> R) rethrows -> R {
    lock()
    defer {
      unlock()
    }
    return try block()
  }
  //
  @inlinable public func locked() -> Bool {
    os_unfair_lock_trylock(_lock)
  }
  //
  @inlinable public func lock() {
    os_unfair_lock_lock(_lock)
  }
  @inlinable public func unlock() {
    os_unfair_lock_unlock(_lock)
  }
  
  // MARK: Public Inits
  public init() {
    _lock = .allocate(capacity: 1)
    _lock.initialize(to: os_unfair_lock())
  }
  deinit {
    _lock.deinitialize(count: 1)
    _lock.deallocate()
  }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, macCatalyst 13.0, *)
extension UnfairLock {
  public enum Predicate {
    case onThreadOwner, notOnThreadOwner
  }
}
