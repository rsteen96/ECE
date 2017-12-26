
//

// BoxScene.swift

// ECE-iOS application

//

// Created by Arlo Miles Cohen on 10/26/17.

// Copyright © 2017 Arlo Miles Cohen. All rights reserved.

//

import SpriteKit
import AVFoundation


private let xyMovable = "xyMovable"
private let xMovable = "xMovable"
private let yMovable = "yMovable"
private let unMovable = "unMovable"
private let skyMovable = "skyMovable"
private let lightMovable = "lightMovable"

struct PhysicsCategory {
    
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Horse     : UInt32 = 0b1        //1
    static let Cloud     : UInt32 = 0b10       //2
    static let Sun       : UInt32 = 0b11       //3
    static let Balloon   : UInt32 = 0b100      //4
    static let Apple     : UInt32 = 0b101      //5
    static let Rain      : UInt32 = 0b110      //6
    static let Lightning : UInt32 = 0b111      //7
    static let lightBulb : UInt32 = 0b1000     //8
    static let Hail      : UInt32 = 0b1001     //9
    static let Snow      : UInt32 = 0b1010     //9
    
}

//each sprite gets assigned a category


public var cloudCounter = 0
class BoxScene: SKScene, SKPhysicsContactDelegate {
    
    //load in "background" sprites
    var background = SKSpriteNode(imageNamed: "paperBackground")
    var sun = SKSpriteNode(imageNamed: "sun")
    var menuButton = SKSpriteNode(imageNamed: "menuButton")
    var lightSwitch = SKSpriteNode(imageNamed: "lightswitch")
    var lightSwitchOn = SKSpriteNode(imageNamed: "lightswitchon")
    var appleTree = SKSpriteNode(imageNamed: "cloud")
    var fartPlayer = AVAudioPlayer()
    var balloonPlayer = AVAudioPlayer()
    
    // Light nodes
    //let sunLightNode = SKLightNode()
    let bulbLightNode = SKLightNode()
    
    //var zoneArray;<zoneCoords>
    
    var selectedNode = SKSpriteNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * 3.14159)
    }
    
    //
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
        sprite.zPosition = 2
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
        sprite.zPosition = 2
        
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
    
    //loads the sprites for the given scene
    func loadSprites(){
        self.background.anchorPoint = CGPoint(x: 0, y: 0)
        self.background.position = CGPoint(x: 0, y: 0)
        self.background.zPosition = -1
        self.background.name = unMovable
        addChild(background)
        let horse = addSprite(xLocation: 150, yLocation: 120, spriteFile: "horse-normal", physicsCategory: 0b1, collidesWith: 0b101, movability: xyMovable, isCircular: false)
        let balloon = addSprite(xLocation: 400, yLocation: 550, spriteFile: "looner", physicsCategory: 0b100, collidesWith: 0b11, movability: yMovable, isCircular: true)
        let sun = addSprite(xLocation: 800, yLocation: 650, spriteFile: "sun", physicsCategory: 0b11, collidesWith: 0b100, movability: lightMovable, isCircular: true)
        let apple = addSprite(xLocation: 450, yLocation: 100, spriteFile: "apple", physicsCategory: 0b101, collidesWith: 0b1, movability: xyMovable, isCircular: true)
        let lightBulb = addSprite(xLocation: 200, yLocation: 400, spriteFile: "lightBulb", physicsCategory: 0b1000, collidesWith: 0, movability: lightMovable, isCircular: true)
        appleTree = addSprite(xLocation: 800, yLocation: 250, spriteFile: "cloud", physicsCategory: 0b10, collidesWith: 0, movability: unMovable, isCircular: true)
        //horse.shadowCastBitMask = 0b0011
        //balloon.shadowCastBitMask = 0b0011
        //apple.shadowCastBitMask = 0b0011
        //lightBulb.shadowCastBitMask = 0b0011
        
        horse.lightingBitMask = 0b0011
        balloon.lightingBitMask = 0b0011
        apple.lightingBitMask = 0b0011
        lightBulb.lightingBitMask = 0b0011
        sun.lightingBitMask = 0b0001
        
        background.lightingBitMask = 0b0011
        
        background.addChild(sun)
        background.addChild(horse)
        background.addChild(balloon)
        background.addChild(apple)
        background.addChild(lightBulb)
        background.addChild(appleTree)
        
        /*
        sunLightNode.position = CGPoint(x: sun.position.x, y: sun.position.y)
        sunLightNode.categoryBitMask = 0b0001
        sunLightNode.lightColor = .yellow
        sunLightNode.ambientColor = .white
        sunLightNode.falloff = 2
        background.addChild(sunLightNode)
         */
        
        bulbLightNode.position = CGPoint(x: lightBulb.position.x, y: lightBulb.position.y)
        bulbLightNode.categoryBitMask = 0b0011
        bulbLightNode.lightColor = .white
        bulbLightNode.falloff = 3
        background.addChild(bulbLightNode)
        bulbLightNode.isEnabled = false
        
        menuButton.position = CGPoint(x: 1000, y: 744)
        menuButton.zPosition = 3
        menuButton.name = unMovable
        menuButton.alpha = 0.15
        
        lightSwitch.position = CGPoint(x: 900, y: 300)
        lightSwitch.zPosition = 1
        lightSwitch.name = unMovable
        lightSwitch.lightingBitMask = 0b0011
        
        lightSwitchOn.position = CGPoint(x: 900, y: 300)
        lightSwitchOn.zPosition = 1
        lightSwitchOn.name = unMovable
        lightSwitchOn.lightingBitMask = 0b0011
        
        background.addChild(menuButton)
        background.addChild(lightSwitch)
    }
    
    //collision detection
    func sunDidCollideWithBalloon(Sun: SKSpriteNode, Balloon: SKSpriteNode) {
        Balloon.removeFromParent()
        self.playSound("balloonburst")
    }
    
    //more collision detection
    func horseAteApple(Horse: SKSpriteNode, Apple: SKSpriteNode){
        Apple.removeFromParent()
        let when = DispatchTime.now() + 3
        
        let fartingHorse = addSprite(location: Horse.position, spriteFile: "horse-farting", physicsCategory: 0b1, collidesWith: 0b100, movability: xyMovable, isCircular: false)
        
        //fart is delayed 3 seconds after the apple is consumed by the horse
        DispatchQueue.main.asyncAfter(deadline: when) {
            fartingHorse.position = Horse.position
            fartingHorse.lightingBitMask = 0b0011
            self.background.addChild(fartingHorse)
            Horse.removeFromParent()
            self.playSound("quickfart")
        }
        
        let when2 = DispatchTime.now() + 4
        
        //fart only lasts one second (4 - 3 = 1), and the horse returns to normal
        DispatchQueue.main.asyncAfter(deadline: when2) {
            let normalHorse = self.addSprite(location: fartingHorse.position, spriteFile: "horse-normal", physicsCategory: 0b1, collidesWith: 0b101, movability: xyMovable, isCircular: false)
            fartingHorse.removeFromParent()
            normalHorse.lightingBitMask = 0b0011
            self.background.addChild(normalHorse)
        }
    }
    
    func lionAteChicken(Lion: SKSpriteNode, Chicken: SKSpriteNode) {
        
        Chicken.removeFromParent()
        print("chicken")
        let when = DispatchTime.now()
        
    }
    
    func createSceneContents() {
        //self.backgroundColor = .black
        self.scaleMode = .aspectFit
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        //if a collision occurs, sets one of the sprites to be firstBody and the other to be secondBody based on
        //their category
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
        if ((firstBody.categoryBitMask == PhysicsCategory.Sun ) &&
            (secondBody.categoryBitMask == PhysicsCategory.Balloon)) {
            if let sun = firstBody.node as? SKSpriteNode, let
                balloon = secondBody.node as? SKSpriteNode {
                sunDidCollideWithBalloon(Sun: sun, Balloon: balloon)
            }
        }
        
        if((firstBody.categoryBitMask == PhysicsCategory.Horse) &&
            (secondBody.categoryBitMask == PhysicsCategory.Apple)){
            if let horse = firstBody.node as? SKSpriteNode, let
                apple = secondBody.node as? SKSpriteNode {
                horseAteApple(Horse: horse, Apple: apple)
            }
        }
        
    }
    
    //handles drag and drop using the pan gesture recognizer
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
                //if selectedNode.physicsBody?.categoryBitMask == PhysicsCategory.Sun {checkSun()}
                
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
    
    //calculates the new position of the dragged sprite (note, doesn't apply for unmovable objects)
    func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position
        if selectedNode.name! == xyMovable {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        } else if selectedNode.name! == lightMovable {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            switch Int((selectedNode.physicsBody?.categoryBitMask)!) {
            //case 3: sunLightNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            case 8: bulbLightNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            default : break
            }
        } else if selectedNode.name! == skyMovable {      //for the sun and clouds
            if position.y + translation.y > 600 && position.y + translation.y < 700  && position.x + translation.x < 900 && position.x + translation.x > 35 {
                selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            }
            else {
                if position.x + translation.x < 900 && position.x + translation.x > 35 {
                    selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y)
                }
            }
        }
        else if selectedNode.name! == xMovable {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            switch node {
            case menuButton:
                if let view = view {
                    
                    let transition:SKTransition = SKTransition.fade(withDuration: 3)
                    let scene:SKScene = MenuScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                    
                }
                
            // Flip light switch
            case lightSwitch:
                bulbLightNode.isEnabled = true
                lightSwitch.removeFromParent()
                self.background.addChild(lightSwitchOn)
                break
                
            case lightSwitchOn:
                bulbLightNode.isEnabled = false
                lightSwitchOn.removeFromParent()
                self.background.addChild(lightSwitch)
                break
            
            case appleTree:
                let apple = addSprite(location: appleTree.position, spriteFile: "apple", physicsCategory: 0b101, collidesWith: 0b1, movability: xyMovable, isCircular: true)
                self.background.addChild(apple)
                selectedNode = apple
                break
                
            default: break
            }
        }
    }
    
    func playSound(_ soundFile: String) {
        
        let soundPath = Bundle.main.path(forResource: "Sounds/" + soundFile, ofType:"wav")!
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if soundFile == "quickfart" {
                
                fartPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                //guard let player = player else {return}
                fartPlayer.prepareToPlay()
                fartPlayer.play()
                
            }
            
            if soundFile == "balloonburst" {
                
                balloonPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                //guard let player = player else {return}
                balloonPlayer.prepareToPlay()
                balloonPlayer.play()
                
            }
                
            else if fartPlayer == nil || balloonPlayer == nil {
                
                print("error")
                
            }
            
        } catch let error {
            
            print(error.localizedDescription)
            
        }
    }
}

