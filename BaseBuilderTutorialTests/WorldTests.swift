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

    func test_update_creaetsJobsFromRecipes() {
        let world = World()
        world.objects[.zero] = .kitchenCounter
        
        XCTAssertEqual(world.jobs.count, 0)
        world.update()
        XCTAssertGreaterThan(world.jobs.count, 0)
    }
    
    // MARK: findEmptyTileNear
    func test_findEmptyTileNear() {
        let world = World()
        world.setTile(position: .zero, tile: .Floor)
        XCTAssertNotNil(world.findEmptyTileNear(.zero))
    }
    
    func test_getEmptyTileNear_outsideRange_returns_nil() {
        let world = World()
        for x in -10 ... 10 {
            for y in -10 ... 10 {
                let point = Vector(x: x, y: y)
                world.setTile(position: point, tile: .Floor)
                world.items[point] = ItemStack(item: Item(name: "an Item"), amount: 1)
            }
        }
        world.setTile(position: Vector(x: -20, y: -20), tile: .Floor)
        
        XCTAssertNil(world.findEmptyTileNear(.zero, maxRadius: 5))
    }
    
    func test_getEmptyTileNear_withZeroItemStack() {
        let world = World()
        world.setTile(position: .zero, tile: .Floor)
        world.items[.zero] = ItemStack(item: Item(name: "An item"), amount: 0)
        XCTAssertNotNil(world.findEmptyTileNear(.zero, maxRadius: 0))
    }
    
    func test_findEmptyTileNear_returnsNil_forWall() {
        let world = World()
        world.setTile(position: .zero, tile: .Wall)
        let result = world.findEmptyTileNear(.zero, maxRadius: 0)
        XCTAssertNil(result)
    }
    
    func test_findEmptyTileNear_returnsNil_forVoid() {
        let world = World()
        XCTAssertEqual(world.tiles[.zero, default: .void], .void)
        let result = world.findEmptyTileNear(.zero, maxRadius: 0)
        XCTAssertNil(result)
    }
    
    func test_findEmptyTileNear_returnsNil_forTileWithObject() {
        let world = World()
        world.setTile(position: .zero, tile: .Floor)
        world.objects[.left] = Object(name: "Some Object", size: Vector(x: 3, y: 1))
        let result = world.findEmptyTileNear(.zero, maxRadius: 0)
        XCTAssertNil(result)
    }
    
    func test_findEmptyTileNear_returnsPoint_ifThereIsEmptyTileInRange() throws {
        let world = World()
        for x in -5 ... 5 {
            for y in -5 ... 5 {
                let point = Vector(x: x, y: y)
                world.setTile(position: point, tile: .Floor)
                if abs(x) <= 3 || abs(y) <= 3 {
                    world.items[point] = ItemStack(item: Item(name: "an Item"), amount: 1)
                } else if abs(x) == 4 || abs(y) == 4 {
                    world.objects[point] = Object(name: "Some Object")
                }
            }
        }
        let result = try XCTUnwrap(world.findEmptyTileNear(.zero, maxRadius: 6))
        
        XCTAssertTrue(abs(result.x) == 5 || abs(result.y) == 5)
    }
    
    // MARK: Can Install Object in world
    func test_object_canBuildInWorld() {
        let testObject = Object(name: "Test Object", allowedTiles: [.void])
        let world = World()
        world.items[.up] = ItemStack(item: testObject.objectItem, amount: 4)
        let result = testObject.canBuildInWorld(world, at: .zero)
        XCTAssertTrue(result)
    }
    
    func test_object_canBuildInWorld_failsForNonEmptyTile() {
        let testObject = Object(name: "Test Object", allowedTiles: [.void])
        let world = World()
        world.objects[.down] = Object(name: "Pre-existing object", size: Vector(x: 1, y: 3))
        XCTAssertFalse(testObject.canBuildInWorld(world, at: .zero))
    }
    
    // Missing test from video series
    func test_object_canBuildInWorld_failsForNonEmptyTile_PartialOverlap() {
        let testObject = Object(name: "Test Object", size: Vector(x: 3, y: 1), allowedTiles: [.void])
        let world = World()
        world.objects[.right] = Object(name: "Pre-existing object", size: Vector(x: 3, y: 1))
        XCTAssertFalse(testObject.canBuildInWorld(world, at: .zero))
    }
    
    func test_object_canBuildInWorld_failsForWrongTileType() {
        let testObject = Object(name: "Test Object", size: Vector(x: 3, y: 1), allowedTiles: [.Floor])
        let world = World()
        world.setTile(position: .left, tile: .Floor)
        XCTAssertEqual(world.tiles[.zero, default: .void], .void)
        XCTAssertFalse(testObject.canBuildInWorld(world, at: .left))
    }
}
