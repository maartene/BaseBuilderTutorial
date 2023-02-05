//
//  TileSpriteManager.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 14/01/2023.
//

import Foundation
import SpriteKit

final class TileSpriteManager: SpriteManager {
    let zPosition: CGFloat
    let cellSize: CGFloat
    
    var tileTextureMap = [String: SKTexture]()
    var tileSpriteMap = [Vector: SKSpriteNode]()
    
    init(cellSize: CGFloat, zPosition: CGFloat = 0) {
        self.cellSize = cellSize
        self.zPosition = zPosition
    }
    
    func redraw(world: World, in scene: SKScene) {
        for tile in world.tiles {
            let spriteName = getSpriteNameForTile(in: world, at: tile.key)
            let texture = getTextureNamed(spriteName)
            
            setTileTexture(texture: texture, position: tile.key, in: scene)
        }
    }
    
    func cleanUp(world: World) {
        // No cleanup needed for tiles: we assume they don't get deleted.
    }
    
    private func setTileTexture(texture: SKTexture, position: Vector, in scene: SKScene) {
        if let node = tileSpriteMap[position] {
            node.texture = texture
        } else {
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: cellSize, height: cellSize)
            node.position = CGPoint(x: cellSize * CGFloat(position.x), y: cellSize * CGFloat(position.y))
            node.zPosition = zPosition
            //node.colorBlendFactor = 1.0
            node.userData = ["tilePosition": position]
            scene.addChild(node)
            tileSpriteMap[position] = node
        }
    }
    
    // Cache tile textures
    private func getTextureNamed(_ textureName: String) -> SKTexture {
        if let texture = tileTextureMap[textureName] {
            return texture
        } else {
            let texture = SKTexture(imageNamed: textureName)
            tileTextureMap[textureName] = texture
            return texture
        }
    }
    
    func getSpriteNameForTile(in world: World, at position: Vector) -> String {
        guard let tile = world.tiles[position] else {
            return " "
        }
        
        guard tile == .Wall else {
            return tile.rawValue
        }
        
        var wallString = "Wall-"
        
        let northTile = world.tiles[position + Vector(x: 0, y: 1), default: .void]
        let westTile = world.tiles[position + Vector(x: -1, y: 0), default: .void]
        let eastTile = world.tiles[position + Vector(x: 1, y: 0), default: .void]
        let southTile = world.tiles[position + Vector(x: 0, y: -1), default: .void]
        
        if northTile == .Wall {
            wallString += "N"
        } else {
            wallString += "_"
        }
        
        if eastTile == .Wall {
            wallString += "E"
        } else {
            wallString += "_"
        }
        
        if southTile == .Wall {
            wallString += "S"
        } else {
            wallString += "_"
        }
        
        if westTile == .Wall {
            wallString += "W"
        } else {
            wallString += "_"
        }
        
        return wallString
    }
}
