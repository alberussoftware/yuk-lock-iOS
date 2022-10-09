//
//  UnfairLock.swift
//  YUKLock
//
//  Created by Ruslan on 09/10/22.
//

import Darwin

// MARK: -
public struct UnfairLock<State>: _Locking, @unchecked Sendable {
  
  @usableFromInline
  internal let __lock: ManagedLock
  
  @inlinable
  public init(uncheckedInitialState initialState: State) {
    __lock = .create(with: initialState)
  }
  
  @inlinable
  public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
    return try __lock.withUnsafeMutablePointers { (header, lock) in
      os_unfair_lock_lock(lock); defer { os_unfair_lock_unlock(lock) }
      return try body(&header.pointee)
    }
  }
  
  @inlinable
  public func withLock<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R {
    return try withLockUnchecked(body)
  }
  
  @inlinable
  public func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R? {
    return try __lock.withUnsafeMutablePointers { (header, lock) in
      guard os_unfair_lock_trylock(lock) else { return nil }; defer { os_unfair_lock_unlock(lock) }
      return try body(&header.pointee)
    }
  }
  
  @inlinable
  public func withLockIfAvailable<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R? {
    return try withLockIfAvailableUnchecked(body)
  }
  
  @usableFromInline
  internal func _preconditionTest(_ condition: Ownership) -> Bool {
    __lock.withUnsafeMutablePointerToElements { (lock) in
      switch condition {
      case .owner:
        os_unfair_lock_assert_owner(lock)
      case .notOwner:
        os_unfair_lock_assert_not_owner(lock)
      }
    }
    return true
  }
  
  @_transparent
  public func precondition(_ condition: Ownership) {
    Swift.precondition(_preconditionTest(condition), "lockPrecondition failure")
  }
}

extension UnfairLock where State == Void {
  
  @inlinable
  public init() {
    self.init(uncheckedInitialState: ())
  }
  
  @inlinable
  public func withLockUnchecked<R>(_ body: () throws -> R) rethrows -> R {
    return try withLockUnchecked { (_) in try body() }
  }
  
  @inlinable
  public func withLock<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R {
    return try withLock { (_) in try body() }
  }
  
  @inlinable
  public func withLockIfAvailableUnchecked<R>(_ body: () throws -> R) rethrows -> R? {
    return try withLockIfAvailableUnchecked { (_) in try body() }
  }
  
  @inlinable
  public func withLockIfAvailable<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R? {
    return try withLockIfAvailable { (_) in try body() }
  }
  
  @available(*, noasync, message: "Use 'withLock' for scoped locking")
  @inlinable
  public func lock() {
    __lock.withUnsafeMutablePointerToElements { (lock) in
      os_unfair_lock_lock(lock)
    }
  }
  
  @available(*, noasync, message: "Use 'withLock' for scoped locking")
  @inlinable
  public func unlock() {
    __lock.withUnsafeMutablePointerToElements { (lock) in
      os_unfair_lock_unlock(lock)
    }
  }
  
  @available(*, noasync, message: "Use 'withLockIfAvailable' for scoped locking")
  @inlinable
  public func lockIfAvailable() -> Bool {
    return __lock.withUnsafeMutablePointerToElements { (lock) in
      return os_unfair_lock_trylock(lock)
    }
  }
}

extension UnfairLock where State: Sendable {
  
  @inlinable
  public init(initialState: State) {
    self.init(uncheckedInitialState: initialState)
  }
}

extension UnfairLock {
  
  // MARK: -
  @usableFromInline
  internal final class ManagedLock: ManagedBuffer<State, os_unfair_lock_s> {
    
    @inlinable
    internal class func create(with initialState: State) -> Self {
      let `self` = create(minimumCapacity: 1) { (buffer) in
        buffer.withUnsafeMutablePointerToElements { (lock) in
          lock.initialize(to: .init())
        }
        return initialState
      }
      return unsafeDowncast(`self`, to: Self.self)
    }
    
    @inlinable
    deinit {
      withUnsafeMutablePointerToElements { (lock) in
        lock.deinitialize(count: 1)
        return
      }
    }
  }
}

extension UnfairLock {
  
  // MARK: -
  public enum Ownership: Hashable, Sendable {
    case owner
    case notOwner
  }
}
