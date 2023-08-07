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
        let testJob = Job.createInstallObjectJob(object: self, at: position)
        
        for requirement in testJob.requirements {
            if requirement.isMet(in: world, by: nil, at: position) == false {
                logger.info("Did not meet requirement: \(requirement.description)")
                return false
            }
        }

        return true

    }
}
