//
//  Object.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 26/04/2023.
//

import Foundation

struct Object {
    let name: String
    let size: Vector
    let installTime: Int
    let sprite: String
    let allowedTiles: [Tile]
    
    init(name: String, size: Vector = .one, installTime: Int = 1, sprite: String? = nil, allowedTiles: [Tile] = [.Floor]) {
        self.name = name
        self.size = size
        self.installTime = installTime
        self.sprite = sprite ?? name
        self.allowedTiles = allowedTiles
    }
    
    var objectItem: Item {
        Item(name: name, sprite: sprite + "_item", preferredPickupStackSize: 1)
    }
    
    func canBuildInWorld(_ world: World, at position: Vector) -> Bool {
//        guard world.objectExistsAt(position) == false else {
//            return false
//        }
//        
//        guard allowedTiles.contains(world.tiles[position, default: .void]) else {
//            return false
//        }
        
        return true
    }
}
