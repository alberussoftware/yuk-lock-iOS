//
//  Locked.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

// MARK: -
@propertyWrapper
@dynamicMemberLookup
public final class Locked<Value, LockType: Locking> {
  // MARK: Internal Props
  @usableFromInline
  internal let lock = LockType()
  @usableFromInline
  internal var value: Value
  
  // MARK: Public Props
  public var wrappedValue: Value {
    _read {
      lock.lock()
      defer { lock.unlock() }
      yield value
    }
    _modify {
      lock.lock()
      defer { lock.unlock() }
      yield &value
    }
  }
  public var projectedValue: Locked { self }
  
  // MARK: Public Methods
  @inlinable
  public func read<T>(_ body: (Value) throws -> T) rethrows -> T  {
    try lock.sync { try body(value) }
  }
  @inlinable
  @discardableResult
  public func write<T>(_ body: (inout Value) throws -> T) rethrows -> T {
    try lock.sync { try body(&value) }
  }
  
  // MARK: Public Subscripts
  @inlinable
  public subscript<Property>(dynamicMember keyPath: KeyPath<Value, Property>) -> Property {
    lock.sync { value[keyPath: keyPath] }
  }
  @inlinable
  public subscript<Property>(dynamicMember keyPath: WritableKeyPath<Value, Property>) -> Property {
    get {
      lock.sync { value[keyPath: keyPath] }
    }
    set {
      lock.sync { value[keyPath: keyPath] = newValue }
    }
  }
  @inlinable
  public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, Property>) -> Property {
    get {
      lock.sync { value[keyPath: keyPath] }
    }
    set {
      lock.sync { value[keyPath: keyPath] = newValue }
    }
  }
  
  // MARK: Public Inits
  @inlinable
  public init(wrappedValue: Value) {
    value = wrappedValue
  }
}

// MARK: -
public typealias UnfairLocked<Value> = Locked<Value, UnfairLock>

// MARK: -
public typealias RecursiveLocked<Value> = Locked<Value, RecursiveLock>
