//
//  GameScene.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import SpriteKit

class GameScene: SKScene {
    static let CELL_SIZE: CGFloat = 16
    
    let world = World.makeDemoWorld()
    
    // Gameloop
    var lastUpdateTime: TimeInterval = 0.0
    let updateInterval: TimeInterval = 0.25
    var remainingUpdateDelay: TimeInterval = 0.0
    
    // Sprite Managers
    let tileSpriteManager = TileSpriteManager(cellSize: CELL_SIZE, zPosition: 0)
    let itemSpriteManager = ItemSpriteManager(cellSize: CELL_SIZE, zPosition: 0.25)
    let entitySpriteManager = EntityTileSpriteManager(cellSize: CELL_SIZE, zPosition: 0.5)
    
    // Some nodes
    var cameraNode: SKCameraNode!
    
    override func didMove(to view: SKView) {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint.zero
        // cameraNode.setScale(cameraScale)
        camera = cameraNode
        
        redraw()
    }
    
    func redraw() {
        tileSpriteManager.redraw(world: world, in: self)
        entitySpriteManager.redraw(world: world, in: self)
        itemSpriteManager.redraw(world: world, in: self)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        remainingUpdateDelay -= deltaTime
        
        if remainingUpdateDelay <= 0 {
            remainingUpdateDelay = updateInterval
            world.update()
            
            redraw()
        }
    }
}
