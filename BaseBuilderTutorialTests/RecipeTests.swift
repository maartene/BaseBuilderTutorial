//
//  RecipeTests.swift
//  BaseBuilderTutorialTests
//
//  Created by Maarten Engels on 10/06/2023.
//

import XCTest
@testable import BaseBuilderTutorial

final class RecipeTests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    let testObject = Object(name: "Test Object")
    let inputItem = Item(name: "Required Item")
    let outputItem = Item(name: "Resulting Item")
    
    func test_createJobAt_createsACraftJob() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2))
        
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
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2))
        
        let job = recipe.createJob(at: .right)
        
        XCTAssertEqual(job.targetPosition, .right)
        
        XCTAssertTrue(job.requirements.contains(where: { requirement in
            switch requirement {
            case .position:
                return true
            default:
                return false
            }
        }))
    }
    
    // Item requirements
    func test_createJobAt_hasItemRequirements() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2))
        
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
            XCTFail("\(itemsRequirement) should be an items requirement.")
            return
        }
        
        XCTAssertEqual(itemStack.item, inputItem)
        XCTAssertEqual(itemStack.amount, 4)

    }
    
    // Object exists in the world requirement
    func test_createJobAt_hasObjectRequirement() {
        let recipe = Recipe(object: testObject, requiredItems: [ItemStack(item: inputItem, amount: 4)], resultingItem: ItemStack(item: outputItem, amount: 2))
        
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
        
        guard case .object(let objectName) = objectRequirement else {
            XCTFail("\(objectRequirement) should be an object requirement.")
            return
        }
        
        XCTAssertEqual(objectName, testObject.name)

    }
}
