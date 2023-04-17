//
//  ItemSpriteManager.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 05/02/2023.
//

import Foundation
import SpriteKit

final class ItemSpriteManager: SpriteManager {
    let cellSize: CGFloat
    let zPosition: CGFloat
    
    var itemTextureMap = [String: SKTexture]()
    var itemSpriteMap = [Vector: SKSpriteNode]()
    
    init (cellSize: CGFloat, zPosition: CGFloat = 0) {
        self.cellSize = cellSize
        self.zPosition = zPosition
    }
    
    func redraw(world: World, in scene: SKScene) {
        for (itemPosition, itemStack) in world.items {
            setItemTexture(item: itemStack.item, at: itemPosition, in: scene)
        }
        
        cleanUp(world: world)
    }
    
    func cleanUp(world: World) {
        var entriesToRemove = [Vector]()
        for (position, node) in itemSpriteMap {
            if let item = node.userData?["item"] as? Item {
                if (world.getItem(named: item.name, at: position)?.amount ?? 0) == 0 {
                    entriesToRemove.append(position)
                }
            }
        }
        
        for remove in entriesToRemove {
            itemSpriteMap[remove]?.removeFromParent()
            itemSpriteMap.removeValue(forKey: remove)
        }
    }
    
    private func setItemTexture(item: Item, at position: Vector, in scene: SKScene) {
        let texture = getTextureNamed(item.sprite)
        
        if let node = itemSpriteMap[position] {
            node.texture = texture
        } else {
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: cellSize, height: cellSize)
            node.position = CGPoint(x: cellSize * CGFloat(position.x), y: cellSize * CGFloat(position.y))
            node.zPosition = zPosition
            // node.userData = ["itemPosition": position] (this gets overwritten in the next line)
            node.userData = ["item": item, "itemPosition": position]
            scene.addChild(node)
            itemSpriteMap[position] = node
        }
    }
    
    // Cache item textures
    private func getTextureNamed(_ textureName: String) -> SKTexture {
        if let texture = itemTextureMap[textureName] {
            return texture
        } else {
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            itemTextureMap[textureName] = texture
            return texture
        }
    }
    
}
