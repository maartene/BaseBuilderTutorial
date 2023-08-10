//
//  RecipeTests.swift
//  BaseBuilderTutorialTests
//
//  Created by Maarten Engels on 10/06/2023.
//

import XCTest
@testable import BaseBuilderTutorial

final class RecipeTests: XCTestCase {
    
    let testObject = Object(name: "Test Object")
    let inputItem = Item(name: "Required Item")
    let outputItem = Item(name: "Resulting Item")
    
    // MARK: Test a single job
    func test_createJobAt_createsACraftJob() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 1)
        
        let job = recipe.createJob(at: .zero)
        
        guard case .craft(let itemStack) = job.jobGoal else {
            XCTFail("Expected a craft job, but found \(job.jobGoal).")
            return
        }
        
        XCTAssertEqual(itemStack.item, outputItem)
        XCTAssertEqual(itemStack.amount, 2)
    }
    
    // Position requirement
    func test_createJobAt_hasPositionRequirement() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 1)
        
        let job = recipe.createJob(at: .right)
        
        XCTAssertEqual(job.targetPosition, .right)
        
        XCTAssertGreaterThan(job.requirements.compactMap( {$0 as? PositionRequirement }).count, 0)
    }
    
    // Item requirements
    func test_createJobAt_hasItemRequirements() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 1)
        
        let job = recipe.createJob(at: .zero)
        
        guard let itemsRequirement = job.requirements.compactMap({$0 as? ItemsRequirement}).first else {
            XCTFail("Expected at least an items requirement.")
            return
        }
                
        XCTAssertEqual(itemsRequirement.itemStack.item, inputItem)
        XCTAssertEqual(itemsRequirement.itemStack.amount, 4)
    }
    
    // Object exists in the world requirement
    func test_createJobAt_hasObjectRequirement() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        let job = recipe.createJob(at: .zero)
        
        guard let objectRequirement = job.requirements.compactMap({$0 as? ObjectRequirement}).first else {
            XCTFail("Expected at least an object requirement.")
            return
        }
        
        XCTAssertEqual(objectRequirement.objectName, testObject.name)

    }
    
    // MARK: Tests for creating jobs in the world
    func test_createJobsInWorld_createsCraftJobs() throws {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        world.objects[.right] = testObject
        
        let jobs = recipe.createJobs(in: world)
        
        XCTAssertEqual(jobs.count, 1)
        
        let job = try XCTUnwrap(jobs.first)
        
        switch job.jobGoal {
        case .craft:
            break
        default:
            XCTFail("Expected a craft job.")
        }
    }
    
    func test_createJobsInWorld_createsMultipleCraftJobs() throws {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        world.objects[.right] = testObject
        world.objects[.left] = testObject
        
        let jobs = recipe.createJobs(in: world)
        
        XCTAssertEqual(jobs.count, 2)
    }
    
    func test_createJobsInWorld_cantCreateMoreThanMaxJobs() {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        // Let there be three objects that can spawn jobs
        world.objects[.right] = testObject
        world.objects[.left] = testObject
        world.objects[.zero] = testObject
        
        let jobs = recipe.createJobs(in: world)
        
        XCTAssertEqual(jobs.count, 2)
    }
    
    func test_createJobsInWorld_cantCreateMoreThanMaxJobs_takingExistingJobsIntoAccount() {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        // Let there be three objects that can spawn jobs
        world.objects[.right] = testObject
        world.objects[.left] = testObject
        
        let jobs = recipe.createJobs(in: world)
        
        for job in jobs {
            world.jobs.enqueue(job)
        }
        
        let extraJobs = recipe.createJobs(in: world)
        
        XCTAssertEqual(extraJobs.count, 0)
    }
    
}
