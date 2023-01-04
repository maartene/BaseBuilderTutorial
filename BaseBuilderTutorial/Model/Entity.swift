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
        guard var currentJob = jobs.peek() else {
            fatalError("Where is the job????")      // this should never happen as we already checked that jobs.count > 0
        }
        
        logger.debug("Entity \(self.name) works on job \(currentJob)")
        
        guard checkRequirements(for: currentJob, in: world) else {
            logger.debug("Did not meet requirements for \(currentJob)")
            return
        }
                
        currentJob.buildTime -= 1
        
        if currentJob.buildTime <= 0 {
            completeJob(currentJob, in: world)
        } else {
            // the "pop"/"push" combo updates the top job.
            _ = jobs.pop()
            jobs.push(currentJob)
        }
    }
    
    private func checkRequirements(for job: Job, in world: World) -> Bool {
        for requirement in job.requirements {
            switch requirement {
            case .position:
                if position != job.targetPosition {
                    jobs.push(Job.createMoveToLocationJob(targetLocation: job.targetPosition))
                    logger.debug("Entity \(self.name) created job \(self.jobs.peek()?.description ?? "nil")")
                    return false
                }
            }
        }
        
        return true
    }
    
    private func completeJob(_ currentJob: Job, in world: World) {
        switch currentJob.jobGoal {
        case .changeTile(let tile):
            world.setTile(position: currentJob.targetPosition, tile: tile)
            _ = jobs.pop()
        case .moveToLocation:
            position = currentJob.targetPosition
            _ = jobs.pop()
        }
        logger.info("Entity \(self.name) finished job \(currentJob)")
    }
}
