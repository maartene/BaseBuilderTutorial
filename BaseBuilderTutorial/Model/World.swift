//
//  World.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

final class World {
    private(set) var tiles = [Vector: Tile]()
    
    var entities = [Entity]()
    
    var jobs = Queue<Job>()
    
    var items = [Vector: ItemStack]()
    
    func update() {
        for entity in entities {
            entity.update(in: self)
        }
    }
    
    func setTile(position: Vector, tile: Tile) {
        tiles[position] = tile
    }
    
    // MARK: Items management
    func getLocationWithItems(_ itemStack: ItemStack) -> Vector? {
        for (location, stack) in items {
            if stack.item.name == itemStack.item.name && stack.amount > 0{
                return location
            }
        }
        
        // if we can't find any location, then we'll return nil.
        return nil
    }
    
    
    // MARK: Demo world
    static func makeDemoWorld() -> World {
        let newWorld = World()
        
        newWorld.makeRoom(bottomLeft: Vector(x: -5, y: -3), topRight: Vector(x: 5, y: 3))
        
        // Show changes to world
        newWorld.makeRoomJobs(bottomLeft: Vector(x: -10, y: 6), topRight: Vector(x: -4, y: 10))
        let entity = Entity(name: "Worker", position: .zero)
        newWorld.entities = [entity]
        
        return newWorld
    }
    
    func makeRoom(bottomLeft: Vector, topRight: Vector) {
        for r in bottomLeft.y ... topRight.y {
            for c in bottomLeft.x ... topRight.x {
                if r == bottomLeft.y || r == topRight.y || c == bottomLeft.x || c == topRight.x {
                    setTile(position: Vector(x: c, y: r), tile: .Wall)
                } else {
                    setTile(position: Vector(x: c, y: r), tile: .Floor)
                }
            }
        }
    }
    
    func makeRoomJobs(bottomLeft: Vector, topRight: Vector) {
        for r in bottomLeft.y ... topRight.y {
            for c in bottomLeft.x ... topRight.x {
                if r == bottomLeft.y || r == topRight.y || c == bottomLeft.x || c == topRight.x {
                    //setTile(position: Vector(x: c, y: r), tile: .Wall)
                    jobs.enqueue(Job(jobGoal: .changeTile(.Wall), targetPosition: Vector(x: c, y: r), requirements: [.position]))
                } else {
                    //setTile(position: Vector(x: c, y: r), tile: .Floor)
                    jobs.enqueue(Job(jobGoal: .changeTile(.Floor), targetPosition: Vector(x: c, y: r), requirements: [.position]))
                }
            }
        }
    }
    
}
