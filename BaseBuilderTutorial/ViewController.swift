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
    }
    
    // resize the UI when the view is resized (for instance when toggling full screen mode)
    override func viewDidLayout() {
        guard guiView != nil && skView != nil else {
            return
        }
        
        guiView?.frame = skView.frame
    }
}

