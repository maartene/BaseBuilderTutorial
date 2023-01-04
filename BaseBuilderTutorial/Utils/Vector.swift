//
//  Vector.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

struct Vector {
    var x: Int
    var y: Int
    
    static var zero: Vector {
        Vector(x: 0, y: 0)
    }
    
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension Vector: Hashable { } 
