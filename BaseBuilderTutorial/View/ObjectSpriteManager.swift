//
//  ObjectSpriteManager.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 18/05/2023.
//

import Foundation
import SpriteKit

final class ObjectSpriteManager: SpriteManager {
    let zPosition: CGFloat
    let cellSize: CGFloat
    
    var objectTextureMap = [String: SKTexture]()
    var objectSpriteMap = [Vector: SKSpriteNode]()
    
    init(cellSize: CGFloat, zPosition: CGFloat = 0) {
        self.cellSize = cellSize
        self.zPosition = zPosition
    }
    
    func redraw(world: World, in scene: SKScene) {
        cleanUp(world: world)
        
        for (objectPosition, object) in world.objects {
            let texture = getTextureNamed(object.sprite)
            
            setObjectTexture(texture: texture, object: object, position: objectPosition, in: scene)
        }
        
        for job in world.allJobs {
            switch job.jobGoal {
            case .installObject(let object):
                let texture = getTextureNamed(object.sprite)
                setObjectTexture(texture: texture, object: object, position: job.targetPosition, in: scene, color: SKColor(calibratedRed: 0, green: 200, blue: 0, alpha: 0.5))
            default:
                break
            }
        }
    }
    
    func cleanUp(world: World) {
        var entriesToRemove = [Vector]()
        for (position, node) in objectSpriteMap {
            if world.objects[position] == nil {
                node.removeFromParent()
                entriesToRemove.append(position)
            }
        }
        
        for entryToRemove in entriesToRemove {
            objectSpriteMap.removeValue(forKey: entryToRemove)
        }
    }
    
    private func setObjectTexture(texture: SKTexture, object: Object, position: Vector, in scene: SKScene, color: SKColor? = nil) {
        let xOffset = -0.5 + CGFloat(object.size.x) / 2.0
        let yOffset = -0.5 + CGFloat(object.size.y) / 2.0
        
        let offset = CGPoint(x: xOffset, y: yOffset)
        
        if let node = objectSpriteMap[position] {
            node.texture = texture
            
            node.position = CGPoint(x: cellSize * CGFloat(position.x), y: cellSize * CGFloat(position.y)) + (offset * cellSize)
            
            node.color = color ?? .white
        } else {
            let node = SKSpriteNode(texture: texture)
            
            node.size = CGSize(width: cellSize * CGFloat(object.size.x), height: cellSize * CGFloat(object.size.y))
            
            node.position = CGPoint(x: cellSize * CGFloat(position.x), y: cellSize * CGFloat(position.y)) + (offset * cellSize)
            node.zPosition = zPosition
            node.colorBlendFactor = 1.0
            node.color = color ?? .white
            node.userData = ["objectPosition": position]
            scene.addChild(node)
            objectSpriteMap[position] = node
        }
    }
    
    // Cache tile textures
    private func getTextureNamed(_ textureName: String) -> SKTexture {
        if let texture = objectTextureMap[textureName] {
            return texture
        } else {
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            objectTextureMap[textureName] = texture
            return texture
        }
    }
}
