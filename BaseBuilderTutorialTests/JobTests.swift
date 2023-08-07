//
//  JobTests.swift
//  BaseBuilderTutorialTests
//
//  Created by Maarten Engels on 04/01/2023.
//

import XCTest
@testable import BaseBuilderTutorial

final class JobTests: XCTestCase {

    func testFetchJob() {
        let world = World()
        let itemToFetch = Item(name: "Fetch me!")
        let entity = Entity(name: "Example Entity", position: .zero)
        //let job = Job(buildTarget: .fetchItems(items: [itemToFetch: 1]), targetPosition: Vector.right, requirements: [.position])
        let job = Job.createFetchItemsJob(itemsToFetch: ItemStack(item: itemToFetch, amount: 1), targetLocation: .right)
        entity.jobs.push(job)
        world.items[.right] = ItemStack(item: itemToFetch, amount: 5)
        
        XCTAssertEqual(entity.inventory[itemToFetch, default: 0], 0)
        
        entity.update(in: world)    // fails, but creates moveToLocation job
        entity.update(in: world)    // succeeds, performs moveToLocation job
        entity.update(in: world)    // succeeds, performs fetchItems
        
        XCTAssertGreaterThanOrEqual(entity.inventory[itemToFetch, default: 0], 1)
        XCTAssertEqual(world.items[.right]?.item, itemToFetch)
        XCTAssertLessThan(world.items[.right]?.amount ?? 0, 5)
    }
    
    func testIncompleteFetchCreatesNewFetchJob() {
        let world = World()
        let itemToFetch = Item(name: "Fetch me!")
        let entity = Entity(name: "Example Entity", position: .zero)
        //let job = Job(buildTarget: .fetchItems(items: [itemToFetch: 10]), targetPosition: Vector.right, requirements: [.position])
        let job = Job.createFetchItemsJob(itemsToFetch: ItemStack(item: itemToFetch, amount: 10), targetLocation: .right)
        entity.jobs.push(job)
        world.items[.right] = ItemStack(item: itemToFetch, amount: 5)
        world.items[.left] = ItemStack(item: itemToFetch, amount: 5)
        
        XCTAssertEqual(entity.jobs.peek()?.targetPosition ?? .zero, .right)
        
        entity.update(in: world)    // fails, but creates moveToLocation job
        entity.update(in: world)    // succeeds, performs moveToLocation job
        entity.update(in: world)    // succeeds, performs fetchItems
        
        XCTAssertEqual(entity.inventory[itemToFetch, default: 0], 5)
        XCTAssertEqual(world.items[.right]?.amount ?? 0, 0)
        XCTAssertEqual(entity.jobs.peek()?.targetPosition ?? .zero, .left)
    }

    // MARK: Install object jobs
    func testInstallObjectJob() {
        let world = World()
        let object = Object(name: "Some object", size: .one, allowedTiles: [.void])
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job.createInstallObjectJob(object: object, at: .zero)
        entity.jobs.push(job)
        entity.inventory[object.objectItem] = 1
    
        XCTAssertNil(world.objects[.zero])
        
        entity.update(in: world)
        
        XCTAssertEqual(world.objects[.zero]?.name ?? "", object.name)
        XCTAssertEqual(entity.inventory[object.objectItem], 0)
    }
    
    func test_installObject_inNonEmptyTile_fails() {
        let world = World()
        let object = Object(name: "Some object", size: .one, allowedTiles: [.void])
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job.createInstallObjectJob(object: object, at: .zero)
        
        world.objects[.zero] = Object(name: "Preexisting object")
        
        entity.jobs.push(job)
        entity.inventory[object.objectItem] = 1
        
        entity.update(in: world)
        
        XCTAssertEqual(world.objects[.zero]?.name ?? "", "Preexisting object")
        XCTAssertEqual(entity.inventory[object.objectItem], 1)
    }
    
    func test_installObject_inNonEmptyTile_forOverlappingLargerObjects_fails() {
        let world = World()
        let object = Object(name: "Some object", size: Vector(x: 3, y: 2), allowedTiles: [.void])
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job.createInstallObjectJob(object: object, at: .zero)
        
        world.objects[Vector(x: 2, y: 1)] = Object(name: "Preexisting object", size: Vector(x: 3, y: 2))
        
        entity.jobs.push(job)
        entity.inventory[object.objectItem] = 1
        
        entity.update(in: world)
        
        XCTAssertFalse(world.objectExistsAt(.zero))
        XCTAssertEqual(world.objects[Vector(x: 2, y: 1)]?.name ?? "", "Preexisting object")
        XCTAssertEqual(entity.inventory[object.objectItem], 1)
    }
    
    func test_installObject_onWrongTime_fails() {
        let world = World()
        let object = Object(name: "Some object", size: .one, allowedTiles: [.Floor])
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job.createInstallObjectJob(object: object, at: .zero)
        
        world.setTile(position: .zero, tile: .Wall)
        
        entity.jobs.push(job)
        entity.inventory[object.objectItem] = 1
        
        entity.update(in: world)
        XCTAssertFalse(world.objectExistsAt(.zero))
        XCTAssertEqual(entity.inventory[object.objectItem], 1)
    }
    
    func test_installObject_missingObjectItem_spawnsFetchJob() {
        let world = World()
        let object = Object(name: "Some object", size: .one)
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job.createInstallObjectJob(object: object, at: .zero)
        
        world.items[.right] = ItemStack(item: object.objectItem, amount: 1)
        entity.jobs.push(job)
        
        if let topJob = entity.jobs.peek() {
            switch topJob.jobGoal {
            case .installObject:
                break
            default:
                XCTFail("Top job should be an installObject job.")
            }
        }
        
        entity.update(in: world)
        
        if let topJob = entity.jobs.peek() {
            switch topJob.jobGoal {
            case .fetchItems:
                break
            default:
                XCTFail("Top job should be a fetchItems job.")
            }
        }
    }
    
    func test_installObject_atWrongLocation_spawnsMoveJob() {
        let world = World()
        let object = Object(name: "Some object", size: .one)
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job.createInstallObjectJob(object: object, at: .right)
        
        entity.inventory[object.objectItem] = 1
        entity.jobs.push(job)
        
        if let topJob = entity.jobs.peek()  {
            switch topJob.jobGoal {
            case .installObject(_):
                break
            default:
                XCTFail("Top job should be an installObject job.")
            }
        }
        
        entity.update(in: world)
        
        if let topJob = entity.jobs.peek()  {
            switch topJob.jobGoal {
            case .moveToLocation:
                break
            default:
                XCTFail("Top job should be an moveToLocation job.")
            }
        }
        
        XCTAssertEqual(entity.jobs.count, 2)
    }
    
    // MARK: Craft jobs
    func test_craftJob_addsToInventory() {
        let itemToCraft = Item(name: "Example Item")
        let craftJob = Job(jobGoal: .craft(ItemStack(item: itemToCraft, amount: 2)), targetPosition: .zero, buildTime: 1, requirements: [])
        
        let world = World()
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.jobs.push(craftJob)
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 0)
        
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 2)
    }
    
    func test_craftJob_addsToExistingInventory() {
        let itemToCraft = Item(name: "Example Item")
        let craftJob = Job(jobGoal: .craft(ItemStack(item: itemToCraft, amount: 2)), targetPosition: .zero, buildTime: 1, requirements: [])
        
        let world = World()
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.inventory[itemToCraft] = 1
        entity.jobs.push(craftJob)
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 1)
        
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 3)
    }
    
    func test_craftJob_withAllRequirements() {
        let itemToCraft = Item(name: "Example Item")
        let requiredObject = Object(name: "Required Object")
        let requiredItem = Item(name: "Required Item")
        
        let itemRequirement = ItemsRequirement(itemStack: ItemStack(item: requiredItem, amount: 2))
        
        let craftJob = Job(jobGoal: .craft(ItemStack(item: itemToCraft, amount: 2)), targetPosition: .right, buildTime: 1, requirements: [PositionRequirement(), ObjectRequirement(objectName: requiredObject.name), itemRequirement])
        
        let world = World()
        world.objects[.right] = requiredObject
        
        let entity = Entity(name: "Example Entity", position: .right)
        entity.jobs.push(craftJob)
        entity.inventory[requiredItem] = 10
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 0)
        
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 2)
    }
    
    func test_craftJob_spawnsStoreJob_afterCrafting_whenMoreThanPreferredStackAmount() throws {
        let itemToCraft = Item(name: "Example Item", preferredPickupStackSize: 10)
        
        let craftJob = Job(jobGoal: .craft(ItemStack(item: itemToCraft, amount: 5)), targetPosition: .zero)
        
        let world = World()
        world.setTile(position: .up, tile: .Floor)
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.jobs.push(craftJob)
        entity.inventory[itemToCraft] = 8
        
        entity.update(in: world)
        
        let topJob = try XCTUnwrap(entity.jobs.peek())
        
        guard case .store(let itemToStoreStack) = topJob.jobGoal else {
            XCTFail("Expected the top job to be a store job, but found \(topJob.jobGoal)")
            return
        }
        
        XCTAssertEqual(itemToStoreStack.item, itemToCraft)
        XCTAssertEqual(itemToStoreStack.amount, itemToCraft.preferredPickupStackSize)
    }
    
    // MARK: Store jobs
    func test_storeJob() throws {
        let itemToStore = Item(name: "Some Item")
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.inventory[itemToStore] = 7
        
        let storeJob = Job.createStoreItemJob(item: itemToStore, amount: 5, at: .zero)
        entity.jobs.push(storeJob)
        
        let world = World()
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToStore, default: 0], 2)
        let storedItemStack = try XCTUnwrap(world.items[.zero])
        XCTAssertEqual(storedItemStack.item, itemToStore)
        XCTAssertEqual(storedItemStack.amount, 5)
    }
    
    func test_storeJob_atWrongPosition_spawnsMoveJob() throws {
        let itemToStore = Item(name: "Some Item")
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.inventory[itemToStore] = 7
        
        let storeJob = Job.createStoreItemJob(item: itemToStore, amount: 5, at: .right)
        entity.jobs.push(storeJob)
        
        let world = World()
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToStore, default: 0], 7)
        
        let topJob = try XCTUnwrap(entity.jobs.peek())
        
        guard case .moveToLocation = topJob.jobGoal else {
            XCTFail("Expected a moveToLocaiton job")
            return
        }
        
        XCTAssertEqual(topJob.targetPosition, .right)
    }
    
    func test_storeJob_fails_atLocationWithItemStack() throws {
        let itemToStore = Item(name: "Some Item")
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.inventory[itemToStore] = 7
        
        let storeJob = Job.createStoreItemJob(item: itemToStore, amount: 5, at: .zero)
        entity.jobs.push(storeJob)
        
        let world = World()
        let preExistingItem = Item(name: "Pre-existing item")
        world.items[.zero] = ItemStack(item: preExistingItem, amount: 100)
        
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToStore, default: 0], 7)
        XCTAssertEqual(world.items[.zero]?.item, preExistingItem)
        XCTAssertEqual(world.items[.zero]?.amount, 100)
    }

    func test_storeJob_succeeds_atLocationWithAZeroItemStack() throws {
        let itemToStore = Item(name: "Some Item")
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.inventory[itemToStore] = 7
        
        let storeJob = Job.createStoreItemJob(item: itemToStore, amount: 5, at: .zero)
        entity.jobs.push(storeJob)
        
        let world = World()
        let preExistingItem = Item(name: "Pre-existing item")
        world.items[.zero] = ItemStack(item: preExistingItem, amount: 0)
        
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToStore, default: 0], 2)
        XCTAssertEqual(world.items[.zero]?.item, itemToStore)
        XCTAssertEqual(world.items[.zero]?.amount, 5)
    }
}
