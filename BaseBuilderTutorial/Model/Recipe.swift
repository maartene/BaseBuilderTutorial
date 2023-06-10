//
//  Recipe.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 10/06/2023.
//

import Foundation

struct Recipe {
    let object: Object
    let requiredItems: [ItemStack]
    let resultingItem: ItemStack
    
    func createJob(at position: Vector) -> Job {
        Job(jobGoal: .craft(resultingItem), targetPosition: position, requirements: requirements)
    }
    
    var requirements: [Requirement] {
        var result: [Requirement] = [.position, .object(objectName: object.name)]
        
        result.append(contentsOf: itemRequirements)
        
        return result
    }
    
    var itemRequirements: [Requirement] {
        requiredItems.map { itemStack in
            Requirement.items(itemStack: itemStack)
        }
    }
}
