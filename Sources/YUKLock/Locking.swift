//
//  Locking.swift
//  YUKLock
//
//  Created by Ruslan on 09/10/22.
//

// MARK: -
internal protocol _Locking {

  associatedtype State
  
  init(uncheckedState initialState: State)

  func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R
  
  func withLock<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R
  
  func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R?
  
  func withLockIfAvailable<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R?
}
