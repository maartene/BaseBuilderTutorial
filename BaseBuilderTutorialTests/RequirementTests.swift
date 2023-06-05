//
//  RequirementTests.swift
//  BaseBuilderTutorialTests
//
//  Created by Maarten Engels on 04/01/2023.
//

import XCTest
@testable import BaseBuilderTutorial

final class RequirementTests: XCTestCase {

    func testUnmetPositionRequirementSpawnsMoveToLocationJob() {
        let world = World()
        XCTAssertEqual(world.tiles.count, 0)
        
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job(jobGoal: .changeTile(.Floor), targetPosition: .right, buildTime: 2, requirements: [.position])
        entity.jobs.push(job)
        
        XCTAssertEqual(entity.jobs.peek()?.buildTime ?? 0, 2)
        
        entity.update(in: world)
        
        XCTAssertGreaterThan(entity.jobs.count, 1, "There should be at least two jobs now")
        
        guard let topJob = entity.jobs.peek() else {
            XCTFail("There should be at least one job.")
            return
        }
        
        switch topJob.jobGoal {
        case .moveToLocation:
            break
        default:
            XCTFail("The top job should now be a moveToLocation job.")
        }
    }
    
    func testMissingItemRequirementsSpawnsFetchJob() {
        let world = World()
        let item = Item(name: "You want me!")
        
        world.items[.right] = ItemStack(item: item, amount: 20)
        
        let entity = Entity(name: "Example Entity", position: .zero)
        
        let job = Job(jobGoal: .changeTile(.Floor), targetPosition: Vector.zero, requirements: [.items(itemStack: ItemStack(item: item, amount: 10))])
        entity.jobs.push(job)
        
        XCTAssertEqual(entity.jobs.count, 1)
        
        entity.update(in: world)
                
        XCTAssertEqual(entity.jobs.count, 2)
        guard let firstJob = entity.jobs.pop(), let secondJob = entity.jobs.pop() else {
            XCTFail("These jobs should not be nil")
            return
        }
        
        switch firstJob.jobGoal {
        case .fetchItems(_):
            break
        default:
            XCTFail("The top job should be a fetch job.")
        }
        
        switch secondJob.jobGoal {
        case .changeTile(_):
            break
        default:
            XCTFail("The top job should be the change tile job.")
        }
    }
    
    func test_job_failsWhenObjectDoesNotExist() {
        let itemToCraft = Item(name: "Example Item")
        let requiredObject = Object(name: "workbench")
        
        let craftJob = Job(jobGoal: .craft(ItemStack(item: itemToCraft, amount: 2)), targetPosition: .zero, buildTime: 1, requirements: [.object(objectName: requiredObject.name)])
        
        let world = World()
        
        let entity = Entity(name: "Example Entity", position: .zero)
        entity.jobs.push(craftJob)
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 0)
        
        entity.update(in: world)
        
        XCTAssertEqual(entity.inventory[itemToCraft, default: 0], 0)
    }
}
