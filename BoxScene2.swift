
//
// BoxScene2.swift
// ECE-iOS application
//
// Created by Arlo Miles Cohen on 10/26/17.
// Copyright © 2017 Arlo Miles Cohen. All rights reserved.
//

import SpriteKit
import AVFoundation

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
    static let Lion      : UInt32 = 0b1001     //9
    static let Chicken   : UInt32 = 0b1010     //10
}

private let xyMovable = "xyMovable"
private let xMovable = "xMovable"
private let yMovable = "yMovable"
private let unMovable = "unMovable"
private let skyMovable = "skyMovable"
private let lightMovable = "lightMovable"

class BoxScene2: SKScene, SKPhysicsContactDelegate {
    
    //Load in "background" sprites
    var background = SKSpriteNode(imageNamed: "paperBackground")
    var sun = SKSpriteNode(imageNamed: "sun")
    
    var menuButton = SKSpriteNode(imageNamed: "menuButton")
    var horseButton = SKSpriteNode(imageNamed: "horseButton")
    var lionButton = SKSpriteNode(imageNamed: "lionButton")
    var chickenButton = SKSpriteNode(imageNamed: "chickenButton")
    
    var isLionThere = false
    var isHorseThere = false
    var isChickenThere = false
    
    var horse = SKSpriteNode(imageNamed: "horse-normal")
    var lion = SKSpriteNode(imageNamed: "lion")
    var chicken = SKSpriteNode(imageNamed: "chicken")
    
    var lightSwitch = SKSpriteNode(imageNamed: "lightswitch")
    var lightSwitchOn = SKSpriteNode(imageNamed: "lightswitchon")
    
    var appleTree = SKSpriteNode(imageNamed: "appleTree")
    var apples: [SKSpriteNode] = []
    
    var audioPlayer = AVAudioPlayer()
    
    let bulbLightNode = SKLightNode()
    var selectedNode = SKSpriteNode()
    
    var applesEaten = 0
    var chickensEaten = 0
    var foodEaten = 0
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            
            if !selectedNode.isEqual(touchedNode) {
                
                selectedNode.removeAllActions()
                selectedNode = touchedNode as! SKSpriteNode
            
            }
        
        }
        
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        loadSprites()
    }
    
    // adds sprites
    func addSprite(xLocation: Double, yLocation: Double, spriteFile: String, depth: CGFloat, physicsCategory: UInt32, collidesWith: UInt32, movability: String, isCircular: Bool) -> SKSpriteNode {
        
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        sprite.name = movability
        sprite.position = CGPoint(x: xLocation, y:yLocation)
        sprite.zPosition = depth
        
        if (isCircular) {
            
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
    func addSprite(location: CGPoint, depth: CGFloat, spriteFile: String, physicsCategory: UInt32, collidesWith: UInt32, movability: String, isCircular: Bool) -> SKSpriteNode {
        
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        sprite.name = movability
        sprite.position = location
        sprite.zPosition = depth
        
        if (isCircular) {
            
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: max(sprite.size.width/2,sprite.size.height/2)) //
        
        } else {
            
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size) // 1
       
        }
        
        sprite.physicsBody?.isDynamic = true // 2
        sprite.physicsBody?.categoryBitMask = physicsCategory // 3
        sprite.physicsBody?.contactTestBitMask = collidesWith // 4
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        return sprite
        
    }
    
    //Loads the sprites (called when the program begins)
    func loadSprites() {
        
        self.background.anchorPoint = CGPoint(x: 0, y: 0)
        self.background.position = CGPoint(x: 0, y: 0)
        self.background.zPosition = -1
        self.background.name = unMovable
        addChild(background)
        
        horse = addSprite(xLocation: 150, yLocation: 100, spriteFile: "horse-normal", depth: 2, physicsCategory: 0b1, collidesWith: 0b101, movability: xMovable, isCircular: false)
        lion = addSprite(xLocation: 800, yLocation: 500, spriteFile: "lion", depth: 2, physicsCategory: 0b1001, collidesWith: 0b1010, movability: xMovable, isCircular: false)
        chicken = addSprite(xLocation: 500, yLocation: 500, spriteFile: "chicken", depth: 2, physicsCategory: 0b1010, collidesWith: 0, movability: xyMovable, isCircular: false)
        let balloon = addSprite(xLocation: 400, yLocation: 550, spriteFile: "looner", depth: 2, physicsCategory: 0b100, collidesWith: 0b11, movability: yMovable, isCircular: true)
        let sun = addSprite(xLocation: 800, yLocation: 650, spriteFile: "sun", depth: 2, physicsCategory: 0b11, collidesWith: 0b100, movability: lightMovable, isCircular: true)
        let lightBulb = addSprite(xLocation: 100, yLocation: 700, spriteFile: "lightBulb", depth: 2, physicsCategory: 0b1000, collidesWith: 0, movability: lightMovable, isCircular: true)
        
        horse.lightingBitMask = 0b0011
        lion.lightingBitMask = 0b0011
        chicken.lightingBitMask = 0b0011
        balloon.lightingBitMask = 0b0011
        lightBulb.lightingBitMask = 0b0011
        sun.lightingBitMask = 0b0001
        background.lightingBitMask = 0b0011
        
        background.addChild(sun)
        background.addChild(horse)
        background.addChild(lion)
        background.addChild(chicken)
        background.addChild(balloon)
        background.addChild(lightBulb)
        background.addChild(appleTree)
        
        menuButton.position = CGPoint(x: 1000, y: 744)
        menuButton.zPosition = 3
        menuButton.name = unMovable
        menuButton.alpha = 0.15
        
        horseButton.position = CGPoint(x: 950, y: 744)
        horseButton.zPosition = 3
        horseButton.name = unMovable
        horseButton.alpha = 0.15
        
        lionButton.position = CGPoint(x: 900, y: 744)
        lionButton.zPosition = 3
        lionButton.name = unMovable
        lionButton.alpha = 0.15
        
        chickenButton.position = CGPoint(x: 850, y: 744)
        chickenButton.zPosition = 3
        chickenButton.name = unMovable
        chickenButton.alpha = 0.15
        
        lightSwitch.position = CGPoint(x: 200, y: 700)
        lightSwitch.zPosition = 1
        lightSwitch.name = unMovable
        lightSwitch.lightingBitMask = 0b0011
        
        lightSwitchOn.position = CGPoint(x: 200, y: 700)
        lightSwitchOn.zPosition = 1
        lightSwitchOn.name = unMovable
        lightSwitchOn.lightingBitMask = 0b0011
        
        appleTree.position = CGPoint(x: 830, y: 140)
        appleTree.zPosition = 2
        appleTree.name = unMovable
        appleTree.lightingBitMask = 0b0011
        
        bulbLightNode.position = CGPoint(x: lightBulb.position.x, y: lightBulb.position.y)
        bulbLightNode.categoryBitMask = 0b0011
        bulbLightNode.lightColor = .white
        bulbLightNode.falloff = 3
        background.addChild(bulbLightNode)
        bulbLightNode.isEnabled = false
        
        background.addChild(menuButton)
        background.addChild(horseButton)
        background.addChild(chickenButton)
        background.addChild(lionButton)
        background.addChild(lightSwitch)
    
    }
    
    //collision detection
    func sunDidCollideWithBalloon(Sun: SKSpriteNode, Balloon: SKSpriteNode) {
        Balloon.removeFromParent()
        self.playSound("balloonburst")
    }
    
    func eat(Eater: SKSpriteNode, EaterName: String, Food: SKSpriteNode, FoodName: String, Gas: String){
        
        if EaterName == "horse"{
            playSound("applechomp")
        }
        
        foodEaten += 1
        let currentFoodEaten = foodEaten
        if FoodName == "chicken" {isChickenThere = false}
        Food.removeFromParent()
        var gasDegree = ""
        let when = DispatchTime.now() + 7
        
        switch foodEaten {
        
        case 1:
            gasDegree = "small"
        case 2:
            gasDegree = "small"
        case 3:
            gasDegree = "medium"
        case 4:
            gasDegree = "medium"
        case 5:
            gasDegree = "loud"
        case 6..<9:
            gasDegree = "loud"
        case _ where currentFoodEaten > 9:  //so that the horse can't eat more than 9 apples
            foodEaten = 0
        default:
            break
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: when){
            if currentFoodEaten == self.foodEaten{
                self.releaseGas(Animal: Eater, AnimalName: EaterName, NoiseLevel: gasDegree)
            }
        }
    }
    
    func releaseGas(Animal: SKSpriteNode, AnimalName: String, NoiseLevel: String) -> Void{
        let position = Animal.position
        
        //we don't have a burping lion sprite
        let gassyAnimal = addSprite(location: position, depth: 2, spriteFile: "farting-horse", physicsCategory: 0b1, collidesWith: 0b100, movability: xyMovable, isCircular: false)
        if AnimalName == "horse"{
            Animal.removeFromParent()
            self.background.addChild(gassyAnimal)
            self.playSound(NoiseLevel+"FartSound")
        } else if AnimalName == "lion"{
            self.playSound("burp")
        }
        
        let gasDuration = DispatchTime.now() + 1
        
        DispatchQueue.main.asyncAfter(deadline: gasDuration){
            if AnimalName == "horse"{
                let normalHorse = self.addSprite(location: position, depth: 2, spriteFile: "horse-normal", physicsCategory: 0b1, collidesWith: 0b101, movability: xyMovable, isCircular: false)
                self.background.addChild(normalHorse)
                gassyAnimal.removeFromParent()
            }
            self.foodEaten = 0
        }
    }
    
    func createSceneContents() {
        self.scaleMode = .aspectFit
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    }
    
    //collision handling
    func didBegin(_ contact: SKPhysicsContact) {
        
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
                let xDistance = apple.position.x-horse.position.x
                let yDistance = apple.position.y-horse.position.y
                let xRange = horse.size.width/2
                let yRange = horse.size.height/5
                print("\n")
                if xDistance > 140, xDistance < 180, yDistance > 0, yDistance < 60{  //mouth
                    eat(Eater: horse, EaterName: "horse", Food: apple, FoodName: "apple", Gas: "fart")
                }
            }
        }
        
        if((firstBody.categoryBitMask == PhysicsCategory.Lion) &&
            (secondBody.categoryBitMask == PhysicsCategory.Chicken)){
            
            if let lion = firstBody.node as? SKSpriteNode, let
                chicken = secondBody.node as? SKSpriteNode {
                print("hit")
                let xDistance = lion.position.x-chicken.position.x
                let yDistance = lion.position.y-chicken.position.y
                print(xDistance)
                print(yDistance)
                if xDistance > 190, xDistance < 250, yDistance < 0, yDistance > -75{
                    print("hit2")
                    eat(Eater: lion, EaterName: "lion", Food: chicken, FoodName: "chicken", Gas: "burp")
                }
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
            } else {
                if position.x + translation.x < 900 && position.x + translation.x > 35 {
                    selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y)
                }
            }
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
                case lionButton:
                    if isLionThere {
                        isLionThere = false
                        lionButton.alpha = 1.0
                        lion.removeFromParent()
                    } else {
                        isLionThere = true
                        lionButton.alpha = 0.15
                        addChild(lion)
                    }
                
                case horseButton:
                    if isHorseThere {
                        isHorseThere = false
                        horseButton.alpha = 1.0
                        horse.removeFromParent()
                    } else {
                        isHorseThere = true
                        horseButton.alpha = 0.15
                        addChild(horse)
                    }
                
                case chickenButton:
                    if isChickenThere {
                        isChickenThere = false
                        chickenButton.alpha = 1.0
                        chicken.removeFromParent()
                    } else {
                        isChickenThere = true
                        chickenButton.alpha = 0.15
                        addChild(chicken)
                    }
                
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
                    
                    playSound("rustle")
                    
                    let when = DispatchTime.now() + 2
                    
                    DispatchQueue.main.asyncAfter(deadline: when){  //after the sound has finished playing, create the apple
                        
                        let xRadius = Double(arc4random_uniform(150))
                        let yRadius = Double(arc4random_uniform(100))
                        let side = Double(arc4random_uniform(3))   //returns random number in range 0-2
                        let height = Double(arc4random_uniform(3))
                         
                        self.setApplePosition(Tree: self.appleTree, xRadius: xRadius, yRadius: yRadius, whichSide: side, whichHeight: height)

                    }
                    
                    break   //end appleTree case
                
                default:
                    break
            }
        }
    }
    
    func setApplePosition(Tree: SKSpriteNode, xRadius: Double, yRadius: Double, whichSide: Double, whichHeight: Double) -> Void{
        
        switch whichSide{
        case 0: //left side
            
            switch whichHeight{
                
            case 0: //lower part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: -xRadius, yRadius: -yRadius)
            case 1: //middle of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: -xRadius, yRadius: 0)
            case 2: //upper part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: -xRadius, yRadius: yRadius)
            default:
                break
                
            }
            
        case 1: //middle
            
            switch whichHeight{
                
            case 0: //lower part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: 0, yRadius: -yRadius)
            case 1: //middle of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: 0, yRadius: 0)
            case 2: //upper part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: 0, yRadius: yRadius)
            default:
                break
                
            }
            
        case 2: //right side
            
            switch whichHeight{
                
            case 0: //lower part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: xRadius, yRadius: -yRadius)
            case 1: //middle of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: xRadius, yRadius: 0)
            case 2: //upper part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: xRadius, yRadius: yRadius)
            default:
                break
                
            }   //end deadline handling
            
        default:
            break
        }
    }
    
    func makeApple(xPosition: Double, yPosition: Double, xRadius: Double, yRadius: Double){
        let apple = self.addSprite(xLocation: xPosition+xRadius, yLocation: yPosition+yRadius, spriteFile: "apple", depth: 3, physicsCategory: 0b101, collidesWith: 0b1, movability: yMovable, isCircular: true)
        self.background.addChild(apple)
        apples.append(apple)
        applyGravity(objects: apples)
    }
    
    func applyGravity(objects: [SKSpriteNode]) -> Void{
        for object in objects{
            if object.position.y >= 25, object.name == yMovable{   //if the apple hasn't hit the ground
                object.position.y-=3.5    //make it hit the ground
            } else if object.position.y <= 25{
                object.name = xyMovable
            }
        }
    }
    
    func playSound(_ soundFile: String) {
        
        let soundPath = Bundle.main.path(forResource: "Sounds/" + soundFile, ofType:"wav")!
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            if audioPlayer == nil{
                print("error")
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        applyGravity(objects: apples)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * 3.14159)
    }
}


