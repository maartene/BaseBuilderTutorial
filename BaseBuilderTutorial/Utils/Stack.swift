//
//  Stack.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

struct Stack<T>: Collection {
    private var storage = [T]()
    
    var startIndex: Int {
        storage.startIndex
    }
    
    var endIndex: Int {
        storage.endIndex
    }
    
    mutating func push(_ element: T) {
        storage.append(element)
    }
    
    mutating func pop() -> T? {
        guard storage.count > 0 else {
            return nil
        }
        
        return storage.removeLast()
    }
    
    func peek() -> T? {
        storage.last
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
