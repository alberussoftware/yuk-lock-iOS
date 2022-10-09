//
//  RecursiveLock.swift
//  YUKLock
//
//  Created by Ruslan on 09/10/22.
//

import Darwin

// MARK: -
public struct RecursiveLock<State>: _Locking, @unchecked Sendable {
  
  @usableFromInline
  internal let __lock: ManagedLock
  
  @inlinable
  public init(uncheckedState initialState: State) {
    __lock = .create(with: initialState)
  }
  
  @inlinable
  public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
    return try __lock.withUnsafeMutablePointers { (header, lock) in
      pthread_mutex_lock(lock); defer { pthread_mutex_unlock(lock) }
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
      guard pthread_mutex_trylock(lock) == 0 else { return nil }; defer { pthread_mutex_unlock(lock) }
      return try body(&header.pointee)
    }
  }
  
  @inlinable
  public func withLockIfAvailable<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R? {
    return try withLockIfAvailableUnchecked(body)
  }
}

extension RecursiveLock where State == Void {
  
  @inlinable
  public init() {
    self.init(uncheckedState: ())
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
      guard pthread_mutex_lock(lock) == 0 else { preconditionFailure() }
      return
    }
  }
  
  @available(*, noasync, message: "Use 'withLock' for scoped locking")
  @inlinable
  public func unlock() {
    __lock.withUnsafeMutablePointerToElements { (lock) in
      pthread_mutex_unlock(lock)
      return
    }
  }
  
  @available(*, noasync, message: "Use 'withLockIfAvailable' for scoped locking")
  @inlinable
  public func lockIfAvailable() -> Bool {
    return __lock.withUnsafeMutablePointerToElements { (lock) in
      return pthread_mutex_trylock(lock) == 0
    }
  }
}

extension RecursiveLock where State: Sendable {
  
  @inlinable
  public init(initialState: State) {
    self.init(uncheckedState: initialState)
  }
}

extension RecursiveLock {
  
  // MARK: -
  @usableFromInline
  internal final class ManagedLock: ManagedBuffer<State, pthread_mutex_t> {
    
    @inlinable
    internal class func create(with initialState: State) -> Self {
      let `self` = create(minimumCapacity: 1) { (buffer) in
        buffer.withUnsafeMutablePointerToElements { (lock) in
          let attr = UnsafeMutablePointer<pthread_mutexattr_t>.allocate(capacity: 1)
          defer {
            guard pthread_mutexattr_destroy(attr) == 0 else { preconditionFailure("'pthread_mutexattr_destroy' failure") }
            attr.deinitialize(count: 1)
            attr.deallocate()
          }
          guard pthread_mutexattr_init(attr) == 0 else { preconditionFailure("'pthread_mutexattr_init' failure") }
          guard pthread_mutexattr_settype(attr, PTHREAD_MUTEX_RECURSIVE) == 0 else { preconditionFailure("'pthread_mutexattr_settype' failure") }
          guard pthread_mutex_init(lock, attr) == 0 else { preconditionFailure("'pthread_mutex_init' failure") }
        }
        return initialState
      }
      return unsafeDowncast(`self`, to: Self.self)
    }
    
    @inlinable
    deinit {
      withUnsafeMutablePointerToElements { (lock) in
        guard pthread_mutex_destroy(lock) == 0 else { preconditionFailure("'pthread_mutex_destroy' failure")}
        lock.deinitialize(count: 1)
        return
      }
    }
  }
}
