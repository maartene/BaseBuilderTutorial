//
//  Job.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

struct Job {
    let jobGoal: JobGoal
    let targetPosition: Vector
    var buildTime: Int
    let requirements: [Requirement]
    
    init(jobGoal: JobGoal, targetPosition: Vector, buildTime: Int = 1, requirements: [Requirement] = []) {
        self.jobGoal = jobGoal
        self.targetPosition = targetPosition
        self.buildTime = buildTime
        self.requirements = requirements
    }
    
    enum JobGoal {
        case changeTile(Tile)
        case moveToLocation
        case fetchItems(ItemStack)
        case installObject(object: Object)
        case craft(ItemStack)
        case store(ItemStack)
        case cancelJobs
    }
}

extension Job: CustomStringConvertible {
    var description: String {
        "\(jobGoal) at: \(targetPosition)"
    }
    
    var debugDescription: String {
        "\(jobGoal) at: \(targetPosition) - buildTime remaining: \(buildTime)"
    }
}

extension Job.JobGoal: CustomStringConvertible {
    var description: String {
        switch self {
//        case .buildImprovement(let improvement):
//            return "Build \(improvement.name)"
        case .changeTile(let tile):
            return "Change tile to \(tile.rawValue)"
        case .fetchItems(let itemStack):
            return "Fetch \(itemStack.amount) \(itemStack.item.name)s"
        case .moveToLocation:
            return "Move to location"
        case .installObject(let object):
            return "Install \(object.name)"
        case .craft(let itemStack):
            return "Craft \(itemStack.amount) \(itemStack.item.name)"
        case .store(let itemStack):
            return "Store \(itemStack.amount) \(itemStack.item.name)"
        case .cancelJobs:
            return "Cancel jobs"
        }
    }
}


// MARK: Convenience builder functions
extension Job {
    static func createMoveToLocationJob(targetLocation: Vector) -> Job {
        Job(jobGoal: .moveToLocation, targetPosition: targetLocation, buildTime: 1)
    }
    
    static func createFetchItemsJob(itemsToFetch: ItemStack, targetLocation: Vector) -> Job {
        Job(jobGoal: .fetchItems(itemsToFetch), targetPosition: targetLocation, buildTime: 1, requirements: [PositionRequirement()])
    }
    
    static func createChangeTileJob(tile: Tile, at position: Vector) -> Job {
        var requirements: [Requirement] = [PositionRequirement()]
        requirements.append(contentsOf: tile.itemRequirements)
        return Job(jobGoal: .changeTile(tile), targetPosition: position, buildTime: tile.buildTime, requirements: requirements)
    }
    
    static func createInstallObjectJob(object: Object, at position: Vector) -> Job {
        return Job(jobGoal: .installObject(object: object), targetPosition: position, buildTime: object.installTime, requirements: [
                NoObjectRequirement(size: object.size),
                ItemsRequirement(itemStack: ItemStack(item: object.objectItem, amount: 1)),
                PositionRequirement(),
                TileRequirement(allowedTiles: object.allowedTiles)])
    }
    
    static func createStoreItemJob(item: Item, amount: Int, at position: Vector) -> Job {
        return Job(jobGoal: .store(ItemStack(item: item, amount: amount)), targetPosition: position, requirements: [PositionRequirement(), NoItemStackRequirement()])
    }
}
