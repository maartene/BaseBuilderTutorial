//
//  Entity.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

class Entity {
    let name: String
    var position: Vector
    let sprite: String
    
    var jobs = Stack<Job>()
    var inventory = [Item: Int]()
    
    init(name: String, position: Vector, sprite: String? = nil) {
        self.name = name
        self.position = position
        self.sprite = sprite ?? name
    }
    
    func update(in world: World) {
        if jobs.isEmpty {
            if let newJob = world.jobs.dequeue() {
                logger.info("Entity \(self.name) picked up job \(newJob)")
                jobs.push(newJob)
            }
        } else {
            workOnJob(in: world)
        }
    }
    
    private func workOnJob(in world: World) {
        guard var currentJob = jobs.peek() else {
            fatalError("Where is the job????")      // this should never happen as we already checked that jobs.count > 0
        }
        
        logger.debug("Entity \(self.name) works on job \(currentJob)")
        
        guard checkRequirements(for: currentJob, in: world) else {
            logger.debug("Did not meet requirements for \(currentJob)")
            return
        }
                
        currentJob.buildTime -= 1
        
        if currentJob.buildTime <= 0 {
            processRequirements(for: currentJob)
            completeJob(currentJob, in: world)
        } else {
            // the "pop"/"push" combo updates the top job.
            _ = jobs.pop()
            jobs.push(currentJob)
        }
    }
    
    private func checkRequirements(for job: Job, in world: World) -> Bool {
        for requirement in job.requirements {
            switch requirement {
            case .position:
                if position != job.targetPosition {
                    jobs.push(Job.createMoveToLocationJob(targetLocation: job.targetPosition))
                    logger.debug("Entity \(self.name) created job \(self.jobs.peek()?.description ?? "nil")")
                    return false
                }
            case .items(let itemStack):
                let inventoryAmount = inventoryFor(item: itemStack.item)
                if inventoryAmount < itemStack.amount {
                    // spawn a 'fetch' job.
                    let fetchStack = ItemStack(item: itemStack.item, amount: itemStack.amount - inventoryAmount)
                    if let fetchLocation = world.getLocationWithItems(fetchStack) {
                        
                        jobs.push(Job.createFetchItemsJob(itemsToFetch: fetchStack, targetLocation: fetchLocation))
                        logger.debug("Entity \(self.name) created job \(self.jobs.peek()?.description ?? "nil")")
                    }
                    return false
                }
            case .noObject(let size):
                for x in job.targetPosition.x ..< job.targetPosition.x + size.x {
                    for y in job.targetPosition.y ..< job.targetPosition.y + size.y {
                        if world.objectExistsAt(Vector(x: x, y: y)) {
                            return false
                        }
                    }
                }
            case .tile(let allowedTiles):
                if allowedTiles.contains(world.tiles[position, default: .void]) == false {
                    return false
                }
            case .object(let objectName):
                break
//                if world.objects[targetPosition]?.name ?? "" != objectName {
//                    return false
//                }
            }
        }
        
        return true
    }
    
    private func processRequirements(for job: Job) {
        for requirement in job.requirements {
            switch requirement {
            case .items(let itemStack):
                consumeItems(itemStack)
            default:
                break
            }
        }
    }
    
    
    private func completeJob(_ currentJob: Job, in world: World) {
        switch currentJob.jobGoal {
        case .changeTile(let tile):
            world.setTile(position: currentJob.targetPosition, tile: tile)
            _ = jobs.pop()
        case .moveToLocation:
            position = currentJob.targetPosition
            _ = jobs.pop()
        case .fetchItems(let itemStack):
            // here we 'pop' first, because fetch might create a substitute job for remaining items.
            _ = jobs.pop()
            fetch(itemStack, in: world)
        case .installObject(let object):
            world.objects[currentJob.targetPosition] = object
            _ = jobs.pop()
        case .craft(let itemStack):
            _ = jobs.pop()
        }
        logger.info("Entity \(self.name) finished job \(currentJob)")
    }
    
    // MARK: Requirement processors
    private func consumeItems(_ itemStack: ItemStack) {
        let existingAmount = inventoryFor(item: itemStack.item)
        assert(existingAmount >= itemStack.amount) // this should be OK as we checked the requirements before
        
        inventory[itemStack.item] = existingAmount - itemStack.amount
    }
    
    // MARK: Job completion handlers
    private func fetch(_ itemStack: ItemStack, in world: World) {
        var remainingAmount = itemStack.amount
        let inventoryAmount = inventory[itemStack.item, default: 0]
        
        if let availableStack = world.items[position] {
            let itemsToTransfer = min(max(itemStack.amount, itemStack.item.preferredPickupStackSize), availableStack.amount)
            remainingAmount = itemStack.amount - itemsToTransfer
            inventory[itemStack.item] = inventoryAmount + itemsToTransfer
            world.items[position]?.amount = availableStack.amount - itemsToTransfer
        }
        
        if remainingAmount > 0 {
            // we weren't able to get enough in one go, so we'll create a new fetch job
            let remainingItemsFetchStack = ItemStack(item: itemStack.item, amount: remainingAmount)
            if let fetchPosition = world.getLocationWithItems(remainingItemsFetchStack) {
                jobs.push(Job.createFetchItemsJob(itemsToFetch: remainingItemsFetchStack, targetLocation: fetchPosition))
            }
        }
    }
    
    // MARK: Inventory management
    private func inventoryFor(item: Item) -> Int {
        inventory[item, default: 0]
    }
}
