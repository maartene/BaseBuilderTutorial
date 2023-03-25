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

class ViewModel: ObservableObject {
    weak var world: World?
    
    @Published var hoverCoord: Vector?
    @Published var hoverTile: Tile?
    @Published var hoverEntity: Entity?
    @Published var hoverItems: ItemStack?
    
    @Published var selectedEntity: Entity?
    
    var selectionModus = SelectionModus.selectSingle
    var selectedTiles = Set<Vector>()
    
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
            createChangeTileJobs(tile: tile)
        default:
            logger.warning("Not supported jobgoal \(currentJobGoal).")
        }
        
        self.currentJobGoal = nil
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
}
