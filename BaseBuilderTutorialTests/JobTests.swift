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

}
