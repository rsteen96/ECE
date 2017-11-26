//
//  MenuScene.swift
//  ECE
//
//  Created by Will McAllister on 11/20/17.
//  Copyright © 2017 Will McAllister. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    var cloudButton = SKSpriteNode()
    let cloudButtonTex = SKTexture(imageNamed: "cloud")
    var horseButton = SKSpriteNode()
    let horseButtonTex = SKTexture(imageNamed: "horse-normal")
    
    override func didMove(to view: SKView) {
        
        cloudButton = SKSpriteNode(texture: cloudButtonTex)
        cloudButton.position = CGPoint(x: frame.midX+250, y: frame.midY)
        horseButton = SKSpriteNode(texture: horseButtonTex)
        horseButton.position = CGPoint(x: frame.midX-250, y: frame.midY)
        
        self.addChild(cloudButton)
        self.addChild(horseButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == cloudButton {
                if let view = view {
                    let transition:SKTransition = SKTransition.fade(withDuration: 3)
                    let scene:SKScene = WeatherScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
            if node == horseButton {
                if let view = view {
                    let transition:SKTransition = SKTransition.fade(withDuration: 3)
                    let scene:SKScene = BoxScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
}
