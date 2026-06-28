//
//  OSUnfairLockProtected.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/28.
//

import Foundation
import os

@propertyWrapper
struct OSUnfairLockProtected<Value: Sendable>: Sendable {
    private let storage: OSUnfairLockStorage
    
    nonisolated final class OSUnfairLockStorage: @unchecked Sendable {
        fileprivate let lock: OSAllocatedUnfairLock<Value>

        init(initialState: Value) {
            self.lock = OSAllocatedUnfairLock(initialState: initialState)
        }

        var value: Value {
            get {
                lock.withLock { $0 }
            }
            set {
                lock.withLock { $0 = newValue }
            }
        }
    }
    
    var wrappedValue: Value {
        get { storage.value }
        nonmutating set {
            storage.value = newValue
        }
    }

    var projectedValue: OSUnfairLockProtected<Value> {
        self
    }
    
    init(wrappedValue: Value) {
        self.storage = OSUnfairLockStorage(initialState: wrappedValue)
    }

    nonisolated func withLock<Result: Sendable>(_ body: @Sendable (inout Value) throws -> Result) rethrows -> Result {
        try storage.lock.withLock(body)
    }

    nonisolated func withLockUnchecked<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        try storage.lock.withLockUnchecked(body)
    }
}
