//
//  ViewController.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Cocoa
import SpriteKit
import GameplayKit
import SwiftUI

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    var scene: GameScene!
    var guiView: NSView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            scene = GameScene()
            scene.scaleMode = .resizeFill
                
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            // Setup the GUI using SwiftUI
            let gui = GUI(viewModel: scene.viewModel)
            let uiController = NSHostingController(rootView: gui)
            addChild(uiController)
            
            uiController.view.frame = view.frame
            view.addSubview(uiController.view)
            guiView = uiController.view
        }
        
        // Gesture recognizers
        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(panHandler))
        panGestureRecognizer.buttonMask = 0x2
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // resize the UI when the view is resized (for instance when toggling full screen mode)
    override func viewDidLayout() {
        guard guiView != nil && skView != nil else {
            return
        }
        
        guiView?.frame = skView.frame
    }
    
    // MARK: Pan and Zoom
    // Pan: drag the map around
    @objc func panHandler(_ gestureRecognize: NSPanGestureRecognizer) {
        // get the position within the view where the gesture event happened.
        let p = gestureRecognize.location(in: skView)
        
        // convert the position within the view to position within the scene
        let scenePoint = skView.convert(p, to: scene)
        
        switch gestureRecognize.state {
        case .began:
            scene.dragPositionStart = scenePoint
        case .changed:
            scene.dragPositionTarget = scenePoint
        case .ended:
            scene.dragPositionStart = nil
        default:
            logger.warning("Unknown state: \(gestureRecognize.state.rawValue)")
        }
    }
    
    // Note: this is macOS only! And is does not use a Gesture Recognizer, but assumes that ViewController is first responder.
    override func scrollWheel(with event: NSEvent) {
        scene.setZoom(delta: event.scrollingDeltaY * 0.1)
    }
}

