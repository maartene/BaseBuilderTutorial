//
//  Stack.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

struct Stack<T> {
    private var storage = [T]()
    
    mutating func push(_ element: T) {
        storage.append(element)
    }
    
    /// the way we remove items from the stack is what seperates it from a queue:
    /// a queue removes the oldest entry we added, a stack removes the last entry we added.
    /// thus, a stack is LIFO: Last In - First Out
    mutating func pop() -> T? {
        guard storage.count > 0 else {
            return nil
        }
        
        return storage.removeLast()
    }
    
    func peek() -> T? {
        storage.last
    }
}

/// 20230105: seperated out the stuff that is required for `Collection` protocol conformance.
extension Stack: Collection {
    var startIndex: Int {
        storage.startIndex
    }
    
    var endIndex: Int {
        storage.endIndex
    }
    
    func index(after i: Int) -> Int {
        storage.index(after: i)
    }
    
    subscript(position: Int) -> T {
        _read {
            yield storage[position]
        }
    }
}
