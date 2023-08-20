//
//  ViewModel.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 27/02/2023.
//

import Foundation
import SwiftUI

enum SelectionModus {
    case selectSingle
    case selectSquare
}

enum IntendedAction {
    case scheduleJob(Job.JobGoal)
    case cancelJobs
}

class ViewModel: ObservableObject {
    weak var world: World?
    
    @Published var hoverCoord: Vector?
    @Published var hoverTile: Tile?
    @Published var hoverEntity: Entity?
    @Published var hoverItems: ItemStack?
    
    
    @Published var selectedEntity: Entity?
    
    var selectionModus = SelectionModus.selectSingle
    var selectedTiles = Set<Vector>()
    
    var hoverObject: Object? {
        if let hoverCoord {
            return world?.objectAt(hoverCoord)
        } else {
            return nil
        }
    }
    
    var buildJobGoals: [(jobGoal: Job.JobGoal, available: Bool)] {
        [
            (.changeTile(.Floor), canMeetItemRequirements(.Floor)),
            (.changeTile(.Wall), canMeetItemRequirements(.Wall))
        ]
    }
    
    var installObjectJobGoals: [(jobGoal: Job.JobGoal, available: Bool)] {
        Object.allObjects.map { object in
            let jobGoal = Job.JobGoal.installObject(object: object)
            let available = world?.itemCount(object.objectItem) ?? 0 > 0
            return (jobGoal, available)
        }
    }
    
    var jobObject: Object? {
        switch currentJobGoal {
        case .installObject(let object):
            return object
        default:
            return nil
        }
    }

    var currentIntendedAction: IntendedAction?
    
    var currentJobGoal: Job.JobGoal? {
        guard case .scheduleJob(let jobGoal) = currentIntendedAction else {
            return nil
        }
            
        return jobGoal
    }
    
    private func canMeetItemRequirements(_ tile: Tile) -> Bool {
        guard let world else {
            return false
        }
        
        for requirement in tile.itemRequirements {
            if requirement.isMet(in: world, by: nil, at: .zero) == false {
                return false
            }
        }
        return true
    }
    
    func finishSelection() {
        
        guard let currentIntendedAction else {
            logger.debug("No current intended action, nothing to do.")
            return
        }
        
        switch currentIntendedAction {
        case .scheduleJob(let currentJobGoal):
            switch currentJobGoal {
            case .changeTile(let tile):
                createChangeTileJobs(tile: tile)
            case .installObject(let object):
                createInstallObjectJob(object: object)
            default:
                logger.warning("Not supported jobgoal \(currentJobGoal).")
            }
        case .cancelJobs:
            cancelJobs()
        }
        
        self.currentIntendedAction = nil
        selectedTiles.removeAll()
        self.selectionModus = .selectSingle
    }
    
    private func createChangeTileJobs(tile: Tile) {
        switch selectionModus {
        case .selectSquare:
            let selectedTilesArray = Array(selectedTiles)
            let sortedSelectedTiles = selectedTilesArray.sorted(by: { v1, v2 in v1.sqrMagnitude > v2.sqrMagnitude })
            
            for position in sortedSelectedTiles {
                let job = Job.createChangeTileJob(tile: tile, at: position)
                world?.jobs.enqueue(job)
            }
        default:
            logger.info("No current seleciton.")
        }
    }
    
    func createInstallObjectJob(object: Object) {
        switch selectionModus {
        case .selectSingle:
            if let position = selectedTiles.first, let world = world, object.canBuildInWorld(world, at: position) {
                let job = Job.createInstallObjectJob(object: object, at: position)
                world.jobs.enqueue(job)
            }
        default:
            logger.info("No current selection ")
        }
    }
    
    private func cancelJobs() {
        switch selectionModus {
        case .selectSquare:
            world?.jobs.removeAll(where: { job in
                selectedTiles.contains(job.targetPosition)
            })
        case .selectSingle:
            // Note: this should not happen, but who knows.
            if let selectedTile = selectedTiles.first {
                world?.jobs.removeAll(where: { job in
                    job.targetPosition == selectedTile
                })
            }
        }
    }
}
