//
//  Entity.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

class Entity {
    enum CheckRequirementsResult {
        case met
        case unmet
        case impossibleToMeetInCurrentWorldState
    }
    
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
         
        switch checkRequirements(for: currentJob, in: world) {
        case .met:
            break
        case .unmet:
            logger.debug("Did not meet requirements for \(currentJob)")
            return
        case .impossibleToMeetInCurrentWorldState:
            _ = jobs.pop()
            world.jobs.enqueue(currentJob)
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
    
    fileprivate func trySpawnFetchJob(for itemStack: ItemStack, in world: World) -> Job? {
        // spawn a 'fetch' job.
        let inventoryAmount = inventoryFor(item: itemStack.item)
        let fetchStack = ItemStack(item: itemStack.item, amount: itemStack.amount - inventoryAmount)
        guard let fetchLocation = world.getLocationWithItems(fetchStack) else {
            return nil
        }
        
        return Job.createFetchItemsJob(itemsToFetch: fetchStack, targetLocation: fetchLocation)
        
    }
    
    private func checkRequirements(for job: Job, in world: World) -> CheckRequirementsResult {
        for requirement in job.requirements {
            if let itemsRequirement = requirement as? ItemsRequirement {
                if itemsRequirement.isMet(in: world, by: self, at: job.targetPosition) == false {
                    logger.info("Did not meet itemsRequirement: \(itemsRequirement.description)")
                    let itemStack = itemsRequirement.itemStack
                    guard let fetchJob = trySpawnFetchJob(for: itemStack, in: world) else {
                        return .impossibleToMeetInCurrentWorldState
                    }
                    jobs.push(fetchJob)
                    logger.debug("Entity \(self.name) created job \(fetchJob.description)")
                    return .unmet
                }
            } else if let positionRequirement = requirement as? PositionRequirement {
                if positionRequirement.isMet(in: world, by: self, at: job.targetPosition) == false {
                    logger.info("Did not meet PositionRequirement: \(positionRequirement.description)")
                    jobs.push(Job.createMoveToLocationJob(targetLocation: job.targetPosition))
                    logger.debug("Entity \(self.name) created job \(self.jobs.peek()?.description ?? "nil")")
                    return .unmet
                }
            } else {
                if requirement.isMet(in: world, by: self, at: job.targetPosition) == false {
                    logger.info("Did not meet requirement: \(requirement.description)")
                    return .unmet
                }
            }
        }
        
        return .met
    }
    
    private func processRequirements(for job: Job) {
        for itemsRequirement in job.requirements.compactMap({ $0 as? ItemsRequirement }) {
            consumeItems(itemsRequirement.itemStack)
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
            craft(itemStack, in: world)
        case .store(let itemStack):
            store(itemStack, in: world)
            _ = jobs.pop()
        default:
            logger.error("Unimplemented job type \(currentJob.jobGoal). Ignoring this job.")
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
    
    private func craft(_ itemStack: ItemStack, in world: World) {
        let existingAmount = inventoryFor(item: itemStack.item)
        let newAmount = existingAmount + itemStack.amount
        inventory[itemStack.item] = newAmount
        if newAmount > itemStack.item.preferredPickupStackSize {
            if let storePosition = world.findEmptyTileNear(position) {
                jobs.push(Job.createStoreItemJob(item: itemStack.item, amount: itemStack.item.preferredPickupStackSize, at: storePosition))
                logger.info("Entity \(self.name) created job \(self.jobs.peek()?.description ?? "nil")")
            }
        }
    }
    
    private func store(_ itemStack: ItemStack, in world: World) {
        let inventoryAmount = inventoryFor(item: itemStack.item)
        
        assert(inventoryAmount >= itemStack.amount)
        
        inventory[itemStack.item] = inventoryAmount - itemStack.amount
        world.items[position] = itemStack
    }
    
    // MARK: Inventory management
    private func inventoryFor(item: Item) -> Int {
        inventory[item, default: 0]
    }
}
