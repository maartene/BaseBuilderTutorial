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
    
    // Drag & Drop
    var startDrag = Vector.zero
    var selectedTiles = Set<Vector>()
    
    // Sprite Managers
    let tileSpriteManager = TileSpriteManager(cellSize: CELL_SIZE, zPosition: 0)
    let itemSpriteManager = ItemSpriteManager(cellSize: CELL_SIZE, zPosition: 0.25)
    let entitySpriteManager = EntityTileSpriteManager(cellSize: CELL_SIZE, zPosition: 0.5)
    
    // Some nodes
    var cameraNode: SKCameraNode!
    
    let viewModel = ViewModel()
    
    var boxSelectSquare = SKShapeNode(rect: .zero)
    
    override func didMove(to view: SKView) {
        viewModel.world = world
        
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint.zero
        // cameraNode.setScale(cameraScale)
        camera = cameraNode
              
        boxSelectSquare.zPosition = 10
        boxSelectSquare.strokeColor = .green
        boxSelectSquare.fillColor = SKColor(white: 1, alpha: 0)
        addChild(boxSelectSquare)
        
        redraw()
    }
    
    func redraw() {
        tileSpriteManager.redraw(world: world, in: self)
        entitySpriteManager.redraw(world: world, in: self)
        itemSpriteManager.redraw(world: world, in: self)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        let nodes = nodes(at: pos)
        
        switch viewModel.selectionModus {
        case .selectSingle:
            for node in nodes {
                if let entityID = node.userData?["entityID"] as? ObjectIdentifier {
                    let selectedEntity = world.entities.first { ObjectIdentifier($0) == entityID }
                    entitySpriteManager.highlightEntity(viewModel.selectedEntity, toggle: false)
                    viewModel.selectedEntity = selectedEntity
                    entitySpriteManager.highlightEntity(selectedEntity)
                }
            }
            viewModel.selectedTiles = Set<Vector>([scenePointToVector(pos)])
        case .selectSquare:
            boxSelectSquare.isHidden = false
            startDrag = scenePointToVector(pos)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        switch viewModel.selectionModus {
        case .selectSquare:
            let dragCoord = scenePointToVector(pos)
            let bottomLeft = Vector(x: dragCoord.x < startDrag.x ? dragCoord.x : startDrag.x, y: dragCoord.y < startDrag.y ? dragCoord.y : startDrag.y)
            let topRight = Vector(x: dragCoord.x > startDrag.x ? dragCoord.x : startDrag.x, y: dragCoord.y > startDrag.y ? dragCoord.y : startDrag.y)
            
            for r in bottomLeft.y ... topRight.y {
                for c in bottomLeft.x ... topRight.x {
                    selectedTiles.insert(Vector(x: c, y: r))
                }
            }
            
            let bottomLeftPoint = vectorToScenePoint(bottomLeft)
            let topRightPoint = vectorToScenePoint(topRight)
            
            let width = max(CGFloat(topRightPoint.x - bottomLeftPoint.x), 1)
            let height = max(CGFloat(topRightPoint.y - bottomLeftPoint.y), 1)
            
            let path = CGPath(rect: CGRect(x: bottomLeftPoint.x, y: bottomLeftPoint.y, width: width, height: height), transform: nil)
            
            boxSelectSquare.path = path
            viewModel.selectedTiles = selectedTiles
        default:
            break
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        viewModel.finishSelection()
        boxSelectSquare.isHidden = true
        selectedTiles.removeAll()
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
