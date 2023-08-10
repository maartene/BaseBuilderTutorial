//
//  Requirement.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

protocol Requirement: CustomStringConvertible {
    func isMet(in world: World, by entity: Entity?, at position: Vector) -> Bool
}

extension Requirement {
    var description: String {
        "\(Self.self)"
    }
}

struct ItemsRequirement: Requirement {
    let itemStack: ItemStack
    
    func isMet(in world: World, by entity: Entity?, at position: Vector) -> Bool {
        if let entity {
            return entity.inventory[itemStack.item, default: 0] >= itemStack.amount
        } else {
            return world.itemCount(itemStack.item) >= itemStack.amount
        }
    }
    
    var description: String {
        "ItemsRequirement: \(itemStack.item.name) - \(itemStack.amount)"
    }
}

struct PositionRequirement: Requirement {
    func isMet(in world: World, by entity: Entity?, at position: Vector) -> Bool {
        guard let entity else {
            return true
        }
        
        return entity.position == position
    }
}

struct NoObjectRequirement: Requirement {
    let size: Vector
    
    func isMet(in world: World, by entity: Entity?, at position: Vector) -> Bool {
        for y in position.y ..< position.y + size.y {
            for x in position.x ..< position.x + size.x {
                if world.objectExistsAt(Vector(x: x, y: y)) {
                    return false
                }
            }
        }
        
        return true
    }
}

struct TileRequirement: Requirement {
    let allowedTiles: [Tile]
    
    func isMet(in world: World, by entity: Entity?, at position: Vector) -> Bool {
        let tile = world.tiles[position, default: .void]
        return allowedTiles.contains(tile)
    }
}

struct ObjectRequirement: Requirement {
    let objectName: String
    
    func isMet(in world: World, by entity: Entity?, at position: Vector) -> Bool {
        guard let object = world.objectAt(position) else {
            return false
        }
        
        return object.name == objectName
    }
}

struct NoItemStackRequirement: Requirement {
    func isMet(in world: World, by entity: Entity?, at position: Vector) -> Bool {
        guard let existingItemStack = world.items[position] else {
            return true
        }
        
        return existingItemStack.amount == 0
    }
}

//
//
//enum Requirement {
//    case tile(allowedTiles: [Tile])
//    case object(objectName: String)
//    case noItemStack
//}
