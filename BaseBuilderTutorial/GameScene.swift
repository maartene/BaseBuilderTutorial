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
    
    let viewModel = ViewModel()
    
    override func didMove(to view: SKView) {
        viewModel.world = world
        
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
        let nodes = nodes(at: pos)
        
        for node in nodes {
            if let entityID = node.userData?["entityID"] as? ObjectIdentifier {
                let selectedEntity = world.entities.first { ObjectIdentifier($0) == entityID }
                entitySpriteManager.highlightEntity(viewModel.selectedEntity, toggle: false)
                viewModel.selectedEntity = selectedEntity
                entitySpriteManager.highlightEntity(selectedEntity)
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        viewModel.finishSelection()
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
            logger.debug("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func scenePointToVector(_ scenePoint: CGPoint) -> Vector {
        Vector(x: Int((scenePoint.x / Self.CELL_SIZE).rounded(.toNearestOrAwayFromZero)), y: Int((scenePoint.y / Self.CELL_SIZE).rounded(.toNearestOrAwayFromZero)))
    }
    
    func vectorToScenePoint(_ vector: Vector) -> CGPoint {
        CGPoint(x: CGFloat(vector.x) * Self.CELL_SIZE, y: CGFloat(vector.y) * Self.CELL_SIZE)
    }
    
    private func hover() {
        let mousePosition = NSEvent.mouseLocation - (view?.window?.frame.origin ?? .zero)
        let scenePoint = (view?.convert(mousePosition, to: self) ?? .zero)
        let hoverVector = scenePointToVector(scenePoint)
        viewModel.hoverCoord = hoverVector
        
        viewModel.hoverTile = world.tiles[hoverVector]
        viewModel.hoverEntity = world.entities.first { $0.position == hoverVector }
        viewModel.hoverItems = world.items[hoverVector]
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        remainingUpdateDelay -= deltaTime
        
        hover()
        
        if remainingUpdateDelay <= 0 {
            remainingUpdateDelay = updateInterval
            world.update()
            
            redraw()
        }
    }
}
