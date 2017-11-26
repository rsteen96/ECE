//

// BoxScene.swift

// ECE-iOS application

//

// Created by Arlo Miles Cohen on 10/26/17.

// Copyright © 2017 Arlo Miles Cohen. All rights reserved.

//

import SpriteKit

private let xyMovable = "xyMovable"
private let xMovable = "xMovable"
private let yMovable = "yMovable"
private let unMovable = "unMovable"

class WeatherScene: SKScene, SKPhysicsContactDelegate {
    
    var background = SKSpriteNode(imageNamed: "background")
    var selectedNode = SKSpriteNode()
    var RainZone = SKSpriteNode(imageNamed: "RainZone")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * 3.14159)
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        
        // 1
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is SKSpriteNode {
            // 2
            if !selectedNode.isEqual(touchedNode) {
                selectedNode.removeAllActions()
                selectedNode = touchedNode as! SKSpriteNode
                // 3
            }
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        loadSprites()
        
    }
    
    // adds sprites
    
    func addSprite(xLocation: Double, yLocation: Double, spriteFile: String, physicsCategory: UInt32, collidesWith: UInt32, movability: String, isCircular: Bool) -> SKSpriteNode {
        
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        sprite.name = movability
        sprite.position = CGPoint(x: xLocation, y:yLocation)
        sprite.zPosition = 1
        if (isCircular)     {
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: max(sprite.size.width/2,sprite.size.height/2)   ) // 1
        } else {
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size) // 1
        }
        
        sprite.physicsBody?.isDynamic = true // 2
        sprite.physicsBody?.categoryBitMask = physicsCategory // 3
        sprite.physicsBody?.contactTestBitMask = collidesWith // 4
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        sprite.physicsBody?.usesPreciseCollisionDetection = true
        
        return sprite
        
    }
    
    //creates a sprite based off the location of another sprite
    func addSprite(location: CGPoint, spriteFile: String, physicsCategory: UInt32, collidesWith: UInt32, movability: String, isCircular: Bool) -> SKSpriteNode {
        
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        sprite.name = movability
        sprite.position = location
        sprite.zPosition = 1
        
        if (isCircular)     {
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: max(sprite.size.width/2,sprite.size.height/2)) // 1
        } else {
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size) // 1
        }
        
        sprite.physicsBody?.isDynamic = true // 2
        sprite.physicsBody?.categoryBitMask = physicsCategory // 3
        sprite.physicsBody?.contactTestBitMask = collidesWith // 4
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        return sprite
        
        
    }
    
    func loadSprites(){
        self.background.anchorPoint = CGPoint(x: 0, y: 0)
        self.background.position = CGPoint(x: 0, y: 0)
        self.background.zPosition = -1
        self.background.name = unMovable
        addChild(background)
        let horse = addSprite(xLocation: 100, yLocation: 100, spriteFile: "horse-normal", physicsCategory: 0b1, collidesWith: 0b11, movability: xyMovable, isCircular: false)
        let balloon = addSprite(xLocation: 400, yLocation: 550, spriteFile: "looner", physicsCategory: 0b100, collidesWith: 0b0, movability: yMovable, isCircular: true)
        //let sun = addSprite(xLocation: 800, yLocation: 650, spriteFile: "sun", physicsCategory: 0b11, collidesWith: 0b1, movability: xMovable, isCircular: true)
        let apple = addSprite(xLocation: 450, yLocation: 100, spriteFile: "apple", physicsCategory: 0b101, collidesWith: 0b1, movability: xyMovable, isCircular: true)
        //let LakeZone = addSprite(xLocation: 150, yLocation: 600, spriteFile: "LakeZone", physicsCategory: 0b111, collidesWith: 0b11, movability: unMovable, isCircular: false)
        //let RainZone = addSprite(xLocation: 100, yLocation: 650, spriteFile: "RainZone", physicsCategory: 0b1000, collidesWith: 0b11, movability: xMovable, isCircular: false)
        //let HailZone = addSprite(xLocation: 300, yLocation: 650, spriteFile: "HailZone", physicsCategory: 0b1001, collidesWith: 0b11, movability: xMovable, isCircular: false)
        //let SnowZone = addSprite(xLocation: 500, yLocation: 650, spriteFile: "SnowZone", physicsCategory: 0b1010, collidesWith: 0b11, movability: xMovable, isCircular: false)
        
        //background.addChild(sun)
        background.addChild(horse)
        background.addChild(balloon)
        background.addChild(apple)
        //background.addChild(LakeZone)
        //background.addChild(RainZone)
        //background.addChild(HailZone)
        //background.addChild(SnowZone)
    }
    
    func sunDidCollideWithLakeZone(Sun: SKSpriteNode, LakeZone: SKSpriteNode) {
        
        cloudCounter+=1
        //print("collides")
        if(cloudCounter%10000==0) {print(cloudCounter)}
        sunDidCollideWithLakeZone(Sun: Sun, LakeZone: LakeZone)
    }
    
    func sunDidCollideWithHorse(Horse: SKSpriteNode, Sun: SKSpriteNode) {
        print("Hit")
        let newHorse = addSprite(location: Horse.position, spriteFile: "looner", physicsCategory: 0b100, collidesWith: 0b0, movability: yMovable, isCircular: true)
        background.addChild(newHorse)
        Horse.removeFromParent()
    }
    
    func horseAteApple(Horse: SKSpriteNode, Apple: SKSpriteNode){
        Apple.removeFromParent()
        print("apple")
        let when = DispatchTime.now() + 3
        
        let fartingHorse = addSprite(location: Horse.position, spriteFile: "horse-farting", physicsCategory: 0b1, collidesWith: 0b100, movability: xyMovable, isCircular: false)
        
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            fartingHorse.position = Horse.position
            self.background.addChild(fartingHorse)
            Horse.removeFromParent()
        }
        
        let when2 = DispatchTime.now() + 4
        
        DispatchQueue.main.asyncAfter(deadline: when2) {
            let normalHorse = self.addSprite(location: fartingHorse.position, spriteFile: "horse-normal", physicsCategory: 0b1, collidesWith: 0b101, movability: xyMovable, isCircular: false)
            fartingHorse.removeFromParent()
            self.background.addChild(normalHorse)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask == PhysicsCategory.Horse ) &&
            (secondBody.categoryBitMask == PhysicsCategory.Sun)) {
            if let horse = firstBody.node as? SKSpriteNode, let
                sun = secondBody.node as? SKSpriteNode {
                sunDidCollideWithHorse(Horse: horse, Sun: sun)
            }
        }
        
        if((firstBody.categoryBitMask == PhysicsCategory.Horse) &&
            (secondBody.categoryBitMask == PhysicsCategory.Apple)){
            if let horse = firstBody.node as? SKSpriteNode, let
                apple = secondBody.node as? SKSpriteNode {
                horseAteApple(Horse: horse, Apple: apple)
            }
        }
        
        if((firstBody.categoryBitMask == PhysicsCategory.Sun) &&
            (secondBody.categoryBitMask == PhysicsCategory.LakeZone)){
            if let LakeZone = firstBody.node as? SKSpriteNode, let
                Sun = secondBody.node as? SKSpriteNode {
                sunDidCollideWithLakeZone(Sun: Sun, LakeZone: LakeZone)
            }
        }
        
    }
    
    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            
            var touchLocation = recognizer.location(in: recognizer.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            self.selectNodeForTouch(touchLocation: touchLocation)
            
        } else if recognizer.state == .changed {
            
            var translation = recognizer.translation(in: recognizer.view!)
            translation = CGPoint(x: translation.x, y: -translation.y)
            self.panForTranslation(translation: translation)
            recognizer.setTranslation(CGPoint(x: 0,y: 0), in: recognizer.view)
            
        } else if recognizer.state == .ended {
            if selectedNode.name != xyMovable && selectedNode.name != xMovable && selectedNode.name != yMovable {
                
                let scrollDuration = 0.2
                let velocity = recognizer.velocity(in: recognizer.view)
                let pos = selectedNode.position
                // This just multiplies your velocity with the scroll duration.
                let p = CGPoint(x: velocity.x * CGFloat(scrollDuration), y: velocity.y * CGFloat(scrollDuration))
                var newPos = CGPoint(x: pos.x + p.x, y: pos.y + p.y)
                newPos = self.boundLayerPos(aNewPosition: newPos)
                selectedNode.removeAllActions()
                let moveTo = SKAction.move(to: newPos, duration: scrollDuration)
                moveTo.timingMode = .easeOut
                selectedNode.run(moveTo)
            }
        }
    }
    
    func boundLayerPos(aNewPosition: CGPoint) -> CGPoint {
        let winSize = self.size
        var retval = aNewPosition
        retval.x = CGFloat(min(retval.x, 0))
        retval.x = CGFloat(max(retval.x, -(background.size.width) + winSize.width))
        retval.y = self.position.y
        return retval
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position
        if selectedNode.name! == xyMovable {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        } else if selectedNode.name! == xMovable {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y)
        } else if selectedNode.name! == yMovable {
            selectedNode.position = CGPoint(x: position.x, y: position.y + translation.y)
        } else if selectedNode.name! == unMovable {
            selectedNode.position = CGPoint(x: position.x, y: position.y)
        } else {
            let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            background.position = self.boundLayerPos(aNewPosition: aNewPosition)
        }
    }
    
    override func didMove(to view: SKView) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(recognizer:)))
        self.view!.addGestureRecognizer(gestureRecognizer)
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
    }
    
}

