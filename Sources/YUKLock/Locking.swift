//
//  Locking.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

// MARK: -
public protocol Locking: AnyObject {
  func sync<R>(_ block: () throws -> R) rethrows -> R
  func trySync<R>(_ block: () throws -> R) rethrows -> R?
  //
  func locked() -> Bool
  //
  func lock()
  func unlock()
  //
  init()
}

extension Locking {
  @inlinable public func sync<R>(_ block: () throws -> R) rethrows -> R {
    lock()
    defer { unlock() }
    return try block()
  }
  @inlinable public func trySync<R>(_ block: () throws -> R) rethrows -> R? {
    guard locked() else { return nil }
    defer { unlock() }
    return try block()
  }
}
