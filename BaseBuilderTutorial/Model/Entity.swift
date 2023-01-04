//
//  Entity.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

class Entity {
    let name: String
    var position: Vector
    
    var jobs = Stack<Job>()
    
    init(name: String, position: Vector) {
        self.name = name
        self.position = position
    }
    
    func update(in world: World) {
        if jobs.isEmpty {
            if let newJob = world.jobs.dequeue() {
                logger.info("Entity \(self.name) picked up job \(newJob)")
                jobs.push(newJob)
            }
        } else {
            workOnJob(in: world)
        }
    }
    
    private func workOnJob(in world: World) {
        guard var currentJob = jobs.pop() else {
            fatalError("Where is the job????")
        }
        
        logger.debug("Entity \(self.name) works on job \(currentJob)")
        
        position = currentJob.targetPosition
        
        currentJob.buildTime -= 1
        
        if currentJob.buildTime <= 0 {
            completeJob(currentJob, in: world)
        } else {
            jobs.push(currentJob)
        }
    }
    
    private func completeJob(_ currentJob: Job, in world: World) {
        switch currentJob.jobGoal {
        case .changeTile(let tile):
            world.setTile(position: currentJob.targetPosition, tile: tile)
        }
        logger.info("Entity \(self.name) finished job \(currentJob)")
    }
}
