//
//  Requirement.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

enum Requirement {
    case position
    case items(itemStack: ItemStack)
    case noObject(size: Vector)
    case tile(allowedTiles: [Tile])
    case object(objectName: String)
    case noItemStack
}
