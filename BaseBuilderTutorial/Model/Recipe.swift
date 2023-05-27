//
//  Recipe.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 27/05/2023.
//

import Foundation

struct Recipe {
    let object: Object
    let requiredItems: [ItemStack]
    let resultingItem: ItemStack
    let maxJobs: Int
    
    func createJob(at position: Vector) -> Job {
        Job(jobGoal: .craft(resultingItem), targetPosition: position, requirements: requirements)
    }
    
    func createJobs(in world: World) -> [Job] {
        let positions = world.objects
            .filter { $0.value.name == object.name }
            .map { $0.key }
        
        let existingJobs = world.jobs.filter { job in
            switch job.jobGoal {
            case .craft(let itemStack):
                return itemStack.item == resultingItem.item && itemStack.amount == resultingItem.amount
            default:
                return false
            }
        }
        
        let jobsToCreate = maxJobs - existingJobs.count

        guard jobsToCreate > 0 else {
            return []
        }
        
        let jobs = positions.map { position in
            createJob(at: position)
        }
        
        return Array(jobs[0 ..< min(jobs.count, jobsToCreate)])
    }
    
    var requirements: [Requirement] {
        var result: [Requirement] = [
            .position,
            .object(objectName: object.name),
        ]
        
        result.append(contentsOf: itemRequirements)
        
        return result
    }
    
    var itemRequirements: [Requirement] {
        requiredItems.map { itemStack in
            Requirement.items(itemStack: itemStack)
        }
    }
}
