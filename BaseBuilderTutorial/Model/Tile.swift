//
//  Tile.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

enum Tile: String {
    case void
    case Floor
    case Wall
    case Grass
    
    var itemRequirements: [ItemsRequirement] {
        switch self {
        case .Floor:
            return [ItemsRequirement(itemStack: ItemStack(item: .woodenBlocks, amount: 1))]
        case .Wall:
            return [ItemsRequirement(itemStack: ItemStack(item: .woodenBlocks, amount: 2))]
        default:
            return []
        }
    }
    
    var buildTime: Int {
        switch self {
        case .Floor:
            return 1
        case .Wall:
            return 3
        default:
            return 0
        }
    }
}

