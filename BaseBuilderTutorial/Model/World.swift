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
    
    var objects = [Vector: Object]()
    
    func update() {
        for entity in entities {
            entity.update(in: self)
        }
        
        createJobsForObjects()
    }
    
    func setTile(position: Vector, tile: Tile) {
        tiles[position] = tile
    }
    
    private func createJobsForObjects() {
        for recipe in Recipe.allRecipes {
            for job in recipe.createJobs(in: self) {
                jobs.enqueue(job)
            }
        }
    }
    
    var allJobs: [Job] {
        var result = Array(jobs)
        
        for entity in entities {
            result.append(contentsOf: entity.jobs)
        }
        
        return result
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
    
    func itemCount(_ item: Item) -> Int {
        let correctItems = items.values.filter { itemStack in
            itemStack.item == item
        }
        
        return correctItems.reduce(0) { result, itemStack in
            result + itemStack.amount
        }
    }
    
    func getItem(named itemName: String, at position: Vector) -> ItemStack? {
        guard let itemStack = items[position] else {
            return nil
        }
        
        guard itemStack.item.name == itemName else {
            return nil
        }
        
        return ItemStack(item: itemStack.item, amount: itemStack.amount)
    }
    
    func findEmptyTileNear(_ position: Vector, maxRadius: Int = 10) -> Vector? {
        var radius = 0
        while radius <= maxRadius {
            for y in position.y - radius ... position.y + radius {
                for x in position.x - radius ... position.x + radius {
                    let point = Vector(x: x, y: y)
                    if tileIsEmpty(point) {
                        return point
                    }
                }
            }
            radius += 1
        }
        return nil
    }
    
    private func tileIsEmpty(_ position: Vector) -> Bool {
        if let existingItemStack = items[position], existingItemStack.amount > 0 {
            return false
        }
        
        if tiles[position, default: .void] == .Wall {
            return false
        }
        
        if tiles[position, default: .void] == .void {
            return false
        }
        
        if objectExistsAt(position) {
            return false
        }
        
        return true
    }
    
    // MARK: Object management
    func objectExistsAt(_ position: Vector) -> Bool {
        objectAt(position) != nil
    }
    
    func objectAt(_ position: Vector) -> Object? {
        for (objectPosition, object) in objects {
            if (objectPosition.x ..< objectPosition.x + object.size.x).contains(position.x) &&
                (objectPosition.y ..< objectPosition.y + object.size.y).contains(position.y) {
                return object
            }
        }
        return nil
    }
    
    // MARK: Demo world
    static func makeDemoWorld() -> World {
        let newWorld = World()
        
        newWorld.makeRoom(bottomLeft: Vector(x: -5, y: -3), topRight: Vector(x: 5, y: 3))
        
        // Show changes to world
        // newWorld.makeRoomJobs(bottomLeft: Vector(x: -10, y: 6), topRight: Vector(x: -4, y: 10))
        
        
        let entity = Entity(name: "Worker", position: .zero)
        newWorld.entities = [entity]
        
        newWorld.items[.right] = ItemStack(item: .woodenBlocks, amount: 100)
        newWorld.items[.down] = ItemStack(item: .food, amount: 10)
        newWorld.items[.left] = ItemStack(item: Object.kitchenCounter.objectItem, amount: 2)
        
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
                    // TODO: cleanup hard coded item here
                    jobs.enqueue(Job(jobGoal: .changeTile(.Wall), targetPosition: Vector(x: c, y: r), requirements: [PositionRequirement(), ItemsRequirement(itemStack: ItemStack(item: Item(name: "Wooden Blocks"), amount: 2))]))
                } else {
                    //setTile(position: Vector(x: c, y: r), tile: .Floor)
                    jobs.enqueue(Job(jobGoal: .changeTile(.Floor), targetPosition: Vector(x: c, y: r), requirements: [PositionRequirement()]))
                }
            }
        }
    }
    
}
