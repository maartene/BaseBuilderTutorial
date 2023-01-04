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
    
    func update() {
        for entity in entities {
            entity.update(in: self)
        }
    }
    
    func setTile(position: Vector, tile: Tile) {
        tiles[position] = tile
    }
    
}
