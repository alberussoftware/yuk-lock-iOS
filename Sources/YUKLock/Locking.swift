//
//  Locking.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, macCatalyst 13.0, *)
public protocol Locking: AnyObject {
	@inlinable func sync<R>(_ block: () throws -> R) rethrows -> R
  @inlinable func trySync<R>(_ block: () throws -> R) rethrows -> R?
  //
  @inlinable func locked() -> Bool
  //
  @inlinable func lock()
  @inlinable func unlock()
  //
  init()
}

extension Locking {
	@inlinable public func sync<R>(_ block: () throws -> R) rethrows -> R {
		lock()
		defer {
			unlock()
		}
		return try block()
	}
  @inlinable public func trySync<R>(_ block: () throws -> R) rethrows -> R? {
    guard locked() else {
      return nil
    }
    defer {
      unlock()
    }
    return try block()
  }
}
