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

}
