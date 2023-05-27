//
//  RecipeTests.swift
//  BaseBuilderTutorialTests
//
//  Created by Maarten Engels on 27/05/2023.
//

import Foundation
import XCTest
@testable import BaseBuilderTutorial

final class RecipeTests: XCTestCase {
    let testObject = Object(name: "Test Object")
    let inputItem = Item(name: "Required Item")
    let outputItem = Item(name: "Resulting Item")
    
    // MARK: Tests for a single job
    func test_createJobAt_createsACraftJob() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        let job = recipe.createJob(at: .zero)
        
        guard case .craft(let itemStack) = job.jobGoal else {
            XCTFail("Expected a craft job.")
            return
        }
        
        XCTAssertEqual(itemStack.item, outputItem)
        XCTAssertEqual(itemStack.amount, 2)
    }
    
    func test_createJobAt_hasPositionRequirement() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        let job = recipe.createJob(at: .right)
        
        XCTAssertEqual(job.targetPosition, .right)
        
        XCTAssertTrue(job.requirements.contains { requirement in
            switch requirement {
            case .position:
                return true
            default:
                return false
            }
        })
    }
    
    func test_createJobAt_hasObjectRequirement() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        let job = recipe.createJob(at: .zero)
        
        guard let objectRequirement = job.requirements.first(where: { requirement in
            switch requirement {
            case .object:
                return true
            default:
                return false
            }
        }) else {
            XCTFail("Expected at least an object requirement.")
            return
        }
        
        guard case .object(let requiredObjectName) = objectRequirement else {
            XCTFail("\(objectRequirement) should be an object requirement.")
            return
        }
        
        XCTAssertEqual(requiredObjectName, testObject.name)
    }
    
    func test_createJobAt_hasItemsRequirement() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        let job = recipe.createJob(at: .zero)
        
        guard let itemsRequirement = job.requirements.first(where: { requirement in
            switch requirement {
            case .items:
                return true
            default:
                return false
            }
        }) else {
            XCTFail("Expected at least an items requirement.")
            return
        }
        
        guard case .items(let itemStack) = itemsRequirement else {
            XCTFail("\(itemsRequirement) should be an object requirement.")
            return
        }
        
        XCTAssertEqual(itemStack.item, inputItem)
        XCTAssertEqual(itemStack.amount, 4)
    }
    
    // MARK: Tests for creating jobs in the world
    func test_createJobsInWorld_createsCraftJobs() {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        world.objects[.right] = testObject
        
        let jobs = recipe.createJobs(in: world)
        
        XCTAssertEqual(jobs.count, 1)
        
        switch jobs[0].jobGoal {
        case .craft:
            break
        default:
            XCTFail("Expected a craft job.")
        }
    }
    
    func test_createJobsInWorld_createsMultipleJobs() {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        // let there be two objects that can spawn jobs
        world.objects[.right] = testObject
        world.objects[.left] = testObject
        
        let jobs = recipe.createJobs(in: world)
        
        XCTAssertEqual(jobs.count, 2)
    }
    
    func test_createJobsInWorld_cantCreateMoreThanMaxJobs() {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        // let there be THREE objects that can spawn jobs
        world.objects[.right] = testObject
        world.objects[.left] = testObject
        world.objects[.zero] = testObject
        
        let jobs = recipe.createJobs(in: world)
        
        XCTAssertEqual(jobs.count, 2)
    }
    
    func test_createJobsInWorld_cantCreateMoreThanMaxJobs_takingExistingJobsIntoAccount() {
        let world = World()
        
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2), maxJobs: 2)
        
        // let there be THREE objects that can spawn jobs
        world.objects[.right] = testObject
        world.objects[.left] = testObject
        
        let jobs = recipe.createJobs(in: world)
        XCTAssertEqual(jobs.count, 2)
        
        for job in jobs {
            world.jobs.enqueue(job)
        }
        
        let extraJobs = recipe.createJobs(in: world)
        XCTAssertEqual(extraJobs.count, 0)
    }
}
