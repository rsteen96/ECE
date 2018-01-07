//
//  MenuScene.swift
//  ECE
//
//  Created by Will McAllister on 11/20/17.
//  Copyright © 2017 Will McAllister. All rights reserved.
//

import Foundation
import SpriteKit

private let unMovable = "unMovable"

class MenuScene: SKScene {
    var cloudButton = SKSpriteNode()
    let cloudButtonTex = SKTexture(imageNamed: "cloud")
    var horseButton = SKSpriteNode()
    let horseButtonTex = SKTexture(imageNamed: "horse-normal")
    var background = SKSpriteNode(imageNamed: "paperBackground")
    
    override func didMove(to view: SKView) {
        
        cloudButton = SKSpriteNode(texture: cloudButtonTex)
        cloudButton.position = CGPoint(x: frame.midX+250, y: frame.midY)
        horseButton = SKSpriteNode(texture: horseButtonTex)
        horseButton.position = CGPoint(x: frame.midX-250, y: frame.midY)
        
        self.addChild(cloudButton)
        self.addChild(horseButton)
    }
    
    
    //Creates and returns a sprite with given properties */
    func addSprite(xLocation: Double, yLocation: Double, zPosition: CGFloat, spriteFile: String, physicsCategory: UInt32, collidesWith: UInt32, movability: String, isCircular: Bool) -> SKSpriteNode {
        
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        sprite.name = movability    //Which axis it can move on
        sprite.position = CGPoint(x: xLocation, y:yLocation)
        sprite.zPosition = zPosition    //3D axis (depth)
        
        if isCircular {
            
            //If the sprite is circular, create a circular physics body that's guaranteed to surround the entire sprite (max)
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: max(sprite.size.width/2,sprite.size.height/2))
            
        }
            
        else {
            
            //If the sprite is non-circular, create a rectangle
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size) // 1
            
        }
        
        sprite.physicsBody?.isDynamic = true // 2
        sprite.physicsBody?.categoryBitMask = physicsCategory // 3
        sprite.physicsBody?.contactTestBitMask = collidesWith // 4
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        sprite.physicsBody?.usesPreciseCollisionDetection = true
        
        return sprite
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == cloudButton {
                if let view = view {
                    let transition:SKTransition = SKTransition.fade(withDuration: 3)
                    let scene:SKScene = WeatherScene2(size: self.size)
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
    
    override init(size: CGSize) {
        
        super.init(size: size)
        self.background.anchorPoint = CGPoint(x: 0, y: 0)
        self.background.position = CGPoint(x: 0, y: 0)
        self.background.zPosition = -1      //don't want the background to get in the way of any other sprites
        self.background.name = unMovable
        addChild(background)
           //load the background and sun when the scene initializes
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
