//
//  UnfairLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 10/19/20.
//

import Foundation

public final class UnfairLock {
  // MARK:
  @usableFromInline
  internal private(set) var _lock: UnsafeMutablePointer<os_unfair_lock>
  
  // MARK: -
  // MARK:
  @inlinable
  public func precondition(condition: Predicate) {
    if condition == .onThreadOwner {
      os_unfair_lock_assert_owner(_lock)
    } else {
      os_unfair_lock_assert_not_owner(_lock)
    }
  }
  
  // MARK:
  @inlinable
  public func trySync<R>(_ block: () throws -> R) rethrows -> R? {
    guard locked() else { return nil }
    defer { unlock() }
    return try block()
  }
  
  @inlinable
  public func sync<R>(_ block: () throws -> R) rethrows -> R {
    lock()
    defer { unlock() }
    return try block()
  }
  
  // MARK:
  @inlinable
  public func locked() -> Bool {
    os_unfair_lock_trylock(_lock)
  }
  
  // MARK:
  @inlinable
  public func lock() {
    os_unfair_lock_lock(_lock)
  }
  
  @inlinable
  public func unlock() {
    os_unfair_lock_unlock(_lock)
  }
  
  // MARK:
  public init() {
    _lock = .allocate(capacity: 1)
    _lock.initialize(to: os_unfair_lock())
  }
  
  deinit {
    _lock.deallocate()
  }
}

// MARK: -
public extension UnfairLock {
  
enum Predicate {
  case onThreadOwner
  case notOnThreadOwner
}
  
}
