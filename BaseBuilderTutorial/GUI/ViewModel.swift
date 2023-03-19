//
//  ViewModel.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 27/02/2023.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    weak var world: World?
    
    @Published var hoverCoord: Vector?
    @Published var hoverTile: Tile?
    @Published var hoverEntity: Entity?
    @Published var hoverItems: ItemStack?
    
    @Published var selectedEntity: Entity?
    
    var buildJobGoals: [(jobGoal: Job.JobGoal, available: Bool)] {
        [
            (.changeTile(.Floor), canMeetItemRequirements(.Floor)),
            (.changeTile(.Wall), canMeetItemRequirements(.Wall))
        ]
    }
    
    var currentJobGoal: Job.JobGoal?
    
    // We want to make sure we only show jobs that we have the items for in the world.
    private func canMeetItemRequirements(_ tile: Tile) -> Bool {
        for requirement in tile.itemRequirements {
            switch requirement {
            case .items(let itemStack):
                if world?.itemCount(itemStack.item) ?? 0 < itemStack.amount {
                    return false
                }
            default:
                break
            }
        }
        return true
    }
    
    func finishSelection() {
        guard let currentJobGoal else {
            logger.debug("No current job goal, can't create job.")
            return
        }
        
        switch currentJobGoal {
        case .changeTile(let tile):
            if let hoverCoord {
                let job = Job.createChangeTileJob(tile: tile, at: hoverCoord)
                world?.jobs.enqueue(job)
            }
        default:
            logger.warning("Not supported jobgoal \(currentJobGoal).")
        }
    }
}
