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

}
