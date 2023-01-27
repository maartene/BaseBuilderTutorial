//
//  SpriteManager.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 14/01/2023.
//

import Foundation
import SpriteKit

protocol SpriteManager {
    var cellSize: CGFloat { get }
    var zPosition: CGFloat { get }
    
    func redraw(world: World, in scene: SKScene)
    func cleanUp(world: World)
}
