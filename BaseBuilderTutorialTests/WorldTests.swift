//
//  WorldTests.swift
//  BaseBuilderTutorialTests
//
//  Created by Maarten Engels on 04/01/2023.
//

import XCTest
@testable import BaseBuilderTutorial

final class WorldTests: XCTestCase {

    func testEntityTakesJobFromQueue() {
        let world = World()
        let job = Job(jobGoal: .changeTile(.Floor), targetPosition: .zero, buildTime: 2)
        let entity = Entity(name: "Test Entities", position: .zero)
        
        world.entities = [entity]
        world.jobs.enqueue(job)
        
        XCTAssertEqual(world.jobs.count, 1)
        XCTAssertEqual(entity.jobs.count, 0)
        
        world.update()
        
        XCTAssertEqual(world.jobs.count, 0)
        XCTAssertEqual(entity.jobs.count, 1)
    }

    func test_world_allJobs() {
        let world = World()
        let entity = Entity(name: "Test Entity", position: .zero)
        world.entities = [entity]
        
        let job1 = Job(jobGoal: .changeTile(.Floor), targetPosition: Vector(x: 3, y: 2), buildTime: 2)
        let job2 = Job(jobGoal: .changeTile(.Floor), targetPosition: Vector(x: 5, y: 6), buildTime: 2)
        
        world.jobs.enqueue(job1)
        entity.jobs.push(job2)
        
        XCTAssertTrue(world.jobs.contains(where: { $0.targetPosition == Vector(x: 3, y: 2) }))
        XCTAssertFalse(world.jobs.contains(where: { $0.targetPosition == Vector(x: 5, y: 6) }))
        XCTAssertTrue(entity.jobs.contains(where: { $0.targetPosition == Vector(x: 5, y: 6) }))
        
        XCTAssertEqual(world.allJobs.count, 2)
        
        XCTAssertTrue(world.allJobs.contains(where: { $0.targetPosition == Vector(x: 3, y: 2) }))
        XCTAssertTrue(world.allJobs.contains(where: { $0.targetPosition == Vector(x: 5, y: 6) }))
    }
}
