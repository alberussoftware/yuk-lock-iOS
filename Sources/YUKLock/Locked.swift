//
//  Locked.swift
//  YUKLock
//
//  Created by Ruslan Lutfullin on 2/7/21.
//

// MARK: -
public typealias UnfairLocked<Value> = Locked<Value, UnfairLock>

// MARK: -
public typealias UnfairRecursiveLocked<Value> = Locked<Value, UnfairRecursiveLock>

// MARK: -
@propertyWrapper
@dynamicMemberLookup
public final class Locked<Value, Lock: Locking> {
  
  // MARK: Internal Props
  @usableFromInline
  internal let lock = Lock.init()
  
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
    return try lock.sync { try body(value) }
  }
  
  @inlinable
  @discardableResult
  public func write<T>(_ body: (inout Value) throws -> T) rethrows -> T {
    return try lock.sync { try body(&value) }
  }
  
  // MARK: Public Subscripts
  public subscript<Property>(dynamicMember keyPath: KeyPath<Value, Property>) -> Property {
    @inlinable
    @inline(__always)
    get {
      return lock.sync { value[keyPath: keyPath] }
    }
  }
  
  public subscript<Property>(dynamicMember keyPath: WritableKeyPath<Value, Property>) -> Property {
    @inlinable
    @inline(__always)
    get {
      return lock.sync { value[keyPath: keyPath] }
    }
    
    @inlinable
    @inline(__always)
    set {
      lock.sync { value[keyPath: keyPath] = newValue }
    }
  }
  
  public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, Property>) -> Property {
    @inlinable
    @inline(__always)
    get {
      return lock.sync { value[keyPath: keyPath] }
    }
    
    @inlinable
    @inline(__always)
    set {
      lock.sync { value[keyPath: keyPath] = newValue }
    }
  }
  
  // MARK: Public Inits
  public init(wrappedValue: Value) {
    value = wrappedValue
  }
}
