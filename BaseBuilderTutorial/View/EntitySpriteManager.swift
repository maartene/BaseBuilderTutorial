//
//  EntitySpriteManager.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 27/01/2023.
//

import Foundation
import SpriteKit

final class EntityTileSpriteManager: SpriteManager {
    let cellSize: CGFloat
    let zPosition: CGFloat
    
    var entityTextureMap = [String: SKTexture]()
    var entitySpriteMap = [ObjectIdentifier: SKSpriteNode]()
    
    init(cellSize: CGFloat, zPosition: CGFloat = 0) {
        self.cellSize = cellSize
        self.zPosition = zPosition
    }
    
    func redraw(world: World, in scene: SKScene) {
        for entity in world.entities {
            setEntityTexture(entity, in: scene)
        }
        
        cleanUp(world: world)
    }
    
    func cleanUp(world: World) {
        let objectIdentifiers = world.entities.map { ObjectIdentifier($0) }
        
        var entitiesToRemove = [ObjectIdentifier]()
        
        for entityID in entitySpriteMap.keys {
            if objectIdentifiers.first(where: { $0 == entityID }) == nil {
                entitiesToRemove.append(entityID)
            }
        }
        
        for entityID in entitiesToRemove {
            entitySpriteMap[entityID]?.removeFromParent()
            entitySpriteMap.removeValue(forKey: entityID)
        }
    }
    
    func highlightEntity(_ entity: Entity?, toggle: Bool = true) {
        guard let entity else {
            return
        }
        
        guard let node = entitySpriteMap[ObjectIdentifier(entity)] else {
            return
        }
        
        if let highlighter = node.childNode(withName: "highlighter") {
            highlighter.isHidden = !toggle
        } else {
            let highlighter = SKShapeNode(circleOfRadius: cellSize / 2.0)
            highlighter.name = "highlighter"
            node.addChild(highlighter)
            highlighter.isHidden = !toggle
        }
    }
    
    private func setEntityTexture(_ entity: Entity, in scene: SKScene) {
        let texture = getTextureNamed(entity.sprite)
        let entityID = ObjectIdentifier(entity)
        
        if let node = entitySpriteMap[entityID] {
            node.texture = texture
            node.position = CGPoint(x: CGFloat(entity.position.x) * cellSize, y: CGFloat(entity.position.y) * cellSize)
        } else {
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: cellSize, height: cellSize)
            node.position = CGPoint(x: CGFloat(entity.position.x) * cellSize, y: CGFloat(entity.position.y) * cellSize)
            node.zPosition = zPosition
            node.userData = ["entityID": entityID]
            scene.addChild(node)
            entitySpriteMap[entityID] = node
        }
    }
    
    // Cache entity textures
    private func getTextureNamed(_ textureName: String) -> SKTexture {
        if let texture = entityTextureMap[textureName] {
            return texture
        } else {
            let texture = SKTexture(imageNamed: textureName)
            entityTextureMap[textureName] = texture
            return texture
        }
            
    }
    
    
    
    
}
