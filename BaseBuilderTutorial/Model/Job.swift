//
//  Job.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

struct Job {
    let jobGoal: JobGoal
    let targetPosition: Vector
    var buildTime: Int
    
    init(jobGoal: JobGoal, targetPosition: Vector, buildTime: Int = 1) {
        self.jobGoal = jobGoal
        self.targetPosition = targetPosition
        self.buildTime = buildTime
    }
    
    enum JobGoal {
        case changeTile(Tile)
    }
}

extension Job: CustomStringConvertible {
    var description: String {
        "\(jobGoal) at: \(targetPosition)"
    }
    
    var debugDescription: String {
        "\(jobGoal) at: \(targetPosition) - buildTime remaining: \(buildTime)"
    }
}
