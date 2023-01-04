//
//  Queue.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

struct Queue<T>: Collection {
    
    private var storage = [T]()
    
    mutating func enqueue(_ element: T) {
        storage.append(element)
    }
    
    mutating func dequeue() -> T? {
        guard storage.count > 0 else {
            return nil
        }
        
        return storage.removeFirst()
    }
    
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
