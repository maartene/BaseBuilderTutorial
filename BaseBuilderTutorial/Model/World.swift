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
    
}
