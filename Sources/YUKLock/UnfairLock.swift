//
//  UnfairLock.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 10/19/20.
//

import Darwin.os.lock

// MARK: -
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, macCatalyst 13.0, *)
public final class UnfairLock: Locking {
  // MARK: Internal Props
  @usableFromInline internal let _lock: os_unfair_lock_t
  
  // MARK: Public Methods
  @inlinable public func lock() {
    os_unfair_lock_lock(_lock)
  }
  @inlinable public func unlock() {
    os_unfair_lock_unlock(_lock)
  }
	//
	@inlinable public func locked() -> Bool {
		os_unfair_lock_trylock(_lock)
	}
  
  // MARK: Public Inits
  public init() {
    _lock = .allocate(capacity: 1)
    _lock.initialize(to: .init())
  }
  deinit {
    _lock.deinitialize(count: 1)
    _lock.deallocate()
  }
}
