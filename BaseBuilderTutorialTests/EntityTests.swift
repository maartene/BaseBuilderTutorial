//
//  EntityTests.swift
//  BaseBuilderTutorialTests
//
//  Created by Maarten Engels on 04/01/2023.
//

import XCTest
@testable import BaseBuilderTutorial

final class EntityTests: XCTestCase {

    func testJobUpdatesLowerBuildTime() {
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job(jobGoal: .changeTile(.Floor), targetPosition: .zero, buildTime: 2)
        entity.jobs.push(job)
        
        let world = World()
        
        XCTAssertEqual(entity.jobs.count, 1)
        XCTAssertEqual(entity.jobs.peek()?.buildTime ?? 0, 2)
        
        entity.update(in: world)
        XCTAssertEqual(entity.jobs.count, 1)
        XCTAssertEqual(entity.jobs.peek()?.buildTime ?? 0, 1)
        
        entity.update(in: world)
        XCTAssertEqual(entity.jobs.count, 0)
    }
    
    func testJobCreatesTile() {
        let world = World()
        XCTAssertEqual(world.tiles.count, 0)
        
        let job = Job(jobGoal: .changeTile(.Floor), targetPosition: .zero, buildTime: 2)
        let entity = Entity(name: "Example Builder", position: .zero)
        entity.jobs.push(job)
        
        XCTAssertEqual(world.tiles[.zero, default: .void], .void)
        
        entity.update(in: world)
        XCTAssertEqual(world.tiles[.zero, default: .void], .void)
        
        entity.update(in: world)
        XCTAssertEqual(world.tiles[.zero, default: .void], .Floor)
        
        XCTAssertEqual(entity.jobs.count, 0)
    }
    
    // MARK: Requirements
    func testUnmetRequirementsDontLowerCycleTime() {
        let world = World()
        XCTAssertEqual(world.tiles.count, 0)
        
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job(jobGoal: .changeTile(.Floor), targetPosition: .right, buildTime: 2, requirements: [.position])
        entity.jobs.push(job)
        
        XCTAssertEqual(entity.jobs.peek()?.buildTime ?? 0, 2)
        
        entity.update(in: world)
        
        XCTAssertEqual(entity.jobs[0].buildTime, 2)
    }
    
    func testMetRequirementsLowerCycleTime() {
        let world = World()
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job(jobGoal: .changeTile(.Wall), targetPosition: .zero, buildTime: 2, requirements: [.position])
        entity.jobs.push(job)
        
        world.setTile(position: .zero, tile: .Floor)

        XCTAssertEqual(entity.jobs.peek()?.buildTime ?? 0, 2)
        entity.update(in: world)
        XCTAssertEqual(entity.jobs.peek()?.buildTime ?? 0, 1)
    }

    func testMeetingRequirementsConsumesItems() {
        let world = World()
        let requiredItem = Item(name: "REQUIRED ITEM")
        let entity = Entity(name: "Example Entity", position: .zero)
        let job = Job(jobGoal: .changeTile(.Wall), targetPosition: .zero, buildTime: 1, requirements: [.items(itemStack: ItemStack(item: requiredItem, amount: 1))])
        entity.jobs.push(job)
        
        world.setTile(position: .zero, tile: .Floor)
        entity.inventory = [requiredItem: 10]

        XCTAssertEqual(entity.inventory[requiredItem, default: 0], 10)
        entity.update(in: world)
        XCTAssertEqual(entity.inventory[requiredItem, default: 0], 9)
    }
    
}
