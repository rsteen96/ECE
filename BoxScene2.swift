
//
// BoxScene2.swift
// ECE-iOS application
//
// Created by Arlo Miles Cohen on 10/26/17.
// Copyright © 2017 Arlo Miles Cohen. All rights reserved.
//
import SpriteKit
import AVFoundation

/*-----------------------------------------------------------------------------------------------------------------------------\\
 
                     ///////////////////////////////////////////////////////////////////////////////////////
                     ////////////////////////////////////// INITIALIZING ///////////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////
 
\\-----------------------------------------------------------------------------------------------------------------------------*/

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
    static let chickenCoop:UInt32 = 0b1011     //11
    static let Hail      : UInt32 = 0b1100     //12
    static let Snow      : UInt32 = 0b1101     //13
    static let snowCap   : UInt32 = 0b1110     //14
    static let horseMouth: UInt32 = 0b1111     //15
    static let lionMouth : UInt32 = 0b10000    //16
}

private let xyMovable = "xyMovable"
private let xMovable = "xMovable"
private let yMovable = "yMovable"
private let unMovable = "unMovable"
private let skyMovable = "skyMovable"
private let lightMovable = "lightMovable"
private let animalMovable = "animalMovable"

class BoxScene2: SKScene, SKPhysicsContactDelegate {
    
    //initializing global nodes for access
    var background = SKSpriteNode(imageNamed: "paperBackground")
    var sun = SKSpriteNode(imageNamed: "sun")
    
    var menuButton = SKSpriteNode(imageNamed: "menuButton")
    var horseButton = SKSpriteNode(imageNamed: "horseButton")
    var lionButton = SKSpriteNode(imageNamed: "lionButton")
    
    //initializing booleans to determine if animal systems are on scene
    var isLionThere = false
    var isHorseThere = false
    
    //initializing animal systems
    var horse = SKSpriteNode(imageNamed: "horse-normal")
    var horseMouth = SKSpriteNode(imageNamed: "mouth")
    var lion = SKSpriteNode(imageNamed: "lion")
    var lionMouth = SKSpriteNode(imageNamed: "mouth")
    
    var appleTree = SKSpriteNode(imageNamed: "appleTreeBig")
    var apples: [SKSpriteNode] = []
    var chickenCoop = SKSpriteNode(imageNamed: "chickenCoop")
    var feathers: [SKSpriteNode] = []
    
    var applesEaten = 0
    var chickensEaten = 0
    var foodEaten = 0
    
    //initializing lightswitch
    var lightSwitch = SKSpriteNode(imageNamed: "lightswitch")
    var lightSwitchOn = SKSpriteNode(imageNamed: "lightswitchon")
    let bulbLightNode = SKLightNode()
    
    //initializing functional necessities
    var selectedNode = SKSpriteNode()
    var audioPlayer = AVAudioPlayer()
    
/*-----------------------------------------------------------------------------------------------------------------------------\\
     
                     ///////////////////////////////////////////////////////////////////////////////////////
                     ////////////////////////////////////// SPRITES ////////////////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////

\\-----------------------------------------------------------------------------------------------------------------------------*/
    
    //creates a sprite based on X and Y coordinates (Doubles)
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
        
        sprite.lightingBitMask = 0b0011
        sprite.physicsBody?.isDynamic = true // 2
        sprite.physicsBody?.categoryBitMask = physicsCategory // 3
        sprite.physicsBody?.contactTestBitMask = collidesWith // 4
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        sprite.physicsBody?.usesPreciseCollisionDetection = true
        
        return sprite
        
    }
    
    //creates a sprite based on the location of another sprite
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
        
        sprite.lightingBitMask = 0b0011
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
        
        let balloon = addSprite(xLocation: 400, yLocation: 550, spriteFile: "looner", depth: 2, physicsCategory: PhysicsCategory.Balloon, collidesWith: PhysicsCategory.Sun, movability: yMovable, isCircular: true)
        let sun = addSprite(xLocation: 800, yLocation: 650, spriteFile: "sun", depth: 2, physicsCategory: PhysicsCategory.Sun, collidesWith: PhysicsCategory.Balloon, movability: lightMovable, isCircular: true)
        let lightBulb = addSprite(xLocation: 100, yLocation: 700, spriteFile: "lightBulb", depth: 2, physicsCategory: PhysicsCategory.lightBulb, collidesWith: PhysicsCategory.None, movability: lightMovable, isCircular: false)
        
        horse = addSprite(xLocation: 150, yLocation: 170, spriteFile: "horse-normal", depth: 2, physicsCategory: PhysicsCategory.Horse, collidesWith: PhysicsCategory.None, movability: animalMovable, isCircular: false)
        horseMouth = addSprite(xLocation: Double(horse.position.x+horse.size.width/2-sun.size.width/2), yLocation: Double(horse.position.y+horse.size.height/2-sun.size.height/2), spriteFile: "sun", depth: -2, physicsCategory: PhysicsCategory.horseMouth, collidesWith: PhysicsCategory.Apple, movability: unMovable, isCircular: true)
        lion = addSprite(xLocation: 800, yLocation: 500, spriteFile: "lion", depth: 2, physicsCategory: PhysicsCategory.None, collidesWith: PhysicsCategory.None, movability: animalMovable, isCircular: false)
        lionMouth = addSprite(xLocation: Double(lion.position.x-lion.size.width/2+sun.size.width/2), yLocation: Double(lion.position.y+lion.size.height/2-sun.size.height/2), spriteFile: "sun", depth: -2, physicsCategory: PhysicsCategory.lionMouth, collidesWith: PhysicsCategory.Chicken, movability: unMovable, isCircular: true)
        
        horse.lightingBitMask = 0b0011
        lion.lightingBitMask = 0b0011
        balloon.lightingBitMask = 0b0011
        lightBulb.lightingBitMask = 0b0011
        sun.lightingBitMask = 0b0001
        background.lightingBitMask = 0b0011
        lightSwitch.lightingBitMask = 0b0011
        lightSwitchOn.lightingBitMask = 0b0011
        appleTree.lightingBitMask = 0b0011
        chickenCoop.lightingBitMask = 0b0011
        bulbLightNode.categoryBitMask = 0b0011
        
        menuButton.position = CGPoint(x: 1000, y: 744)
        menuButton.zPosition = 3
        menuButton.name = unMovable
        menuButton.alpha = 0.15
        
        horseButton.position = CGPoint(x: 950, y: 740)
        horseButton.zPosition = 3
        horseButton.name = unMovable
        horseButton.alpha = 1.0
        
        lionButton.position = CGPoint(x: 900, y: 744)
        lionButton.zPosition = 3
        lionButton.name = unMovable
        lionButton.alpha = 1.0
        
        lightSwitch.position = CGPoint(x: 200, y: 700)
        lightSwitch.zPosition = 1
        lightSwitch.name = unMovable
        
        lightSwitchOn.position = CGPoint(x: 200, y: 700)
        lightSwitchOn.zPosition = 1
        lightSwitchOn.name = unMovable
        
        appleTree.position = CGPoint(x: 680, y: 275)
        appleTree.zPosition = 0
        appleTree.name = unMovable
        
        chickenCoop.position = CGPoint(x: 500, y: 200)
        chickenCoop.zPosition = 1
        chickenCoop.name = unMovable
        
        bulbLightNode.position = CGPoint(x: lightBulb.position.x, y: lightBulb.position.y)
        bulbLightNode.lightColor = .white
        bulbLightNode.falloff = 1
        background.addChild(bulbLightNode)
        bulbLightNode.isEnabled = false
        
        background.addChild(sun)
        background.addChild(balloon)
        background.addChild(lightBulb)
        background.addChild(menuButton)
        background.addChild(horseButton)
        background.addChild(lionButton)
        background.addChild(lightSwitch)
        
    }
    
/*-----------------------------------------------------------------------------------------------------------------------------\\
     
                     ///////////////////////////////////////////////////////////////////////////////////////
                     ///////////////////////////////// ANIMAL SYSTEMS METHODS //////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////
     
\\-----------------------------------------------------------------------------------------------------------------------------*/
    
    func eat(eater: SKSpriteNode, eaterName: String, food: SKSpriteNode, foodName: String, gas: String){
        
        if eaterName == "horse"{
            playSound("applechomp")
            if let index = apples.index(of: food) {
                apples.remove(at: index)
            }
        } else if eaterName == "lion"{
            playSound("chickenSound")
        }
        
        foodEaten += 1
        let currentFoodEaten = foodEaten
        food.removeFromParent()
        var gasDegree = ""
        let when = DispatchTime.now() + 3
        
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
            gasDegree = "loud"
        default:
            print("error: default switch in eat method hit")
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: when){
            if currentFoodEaten == self.foodEaten{
                self.releaseGas(animal: eater, animalName: eaterName, noiseLevel: gasDegree)
            }
        }
    }
    
    func releaseGas(animal: SKSpriteNode, animalName: String, noiseLevel: String) -> Void{
        let position = animal.position
        
        //we don't have a burping lion sprite
        let gassyAnimal = addSprite(location: position, depth: 2, spriteFile: "horse-farting", physicsCategory: PhysicsCategory.Horse, collidesWith: PhysicsCategory.None, movability: unMovable, isCircular: false)
        if animalName == "horse" {
            
            self.playSound(noiseLevel+"FartSound")
            horse.removeFromParent()
            horseMouth.removeFromParent()
            self.background.addChild(gassyAnimal)
            self.foodEaten = 0
            
            let gasDuration = DispatchTime.now() + 1
            
            DispatchQueue.main.asyncAfter(deadline: gasDuration){
                self.background.addChild(self.horse)
                self.background.addChild(self.horseMouth)
                gassyAnimal.removeFromParent()
            }
            
            
        } else if animalName == "lion" {
            
            self.playSound("burp")
            
            let featherLocation = CGPoint(x: lion.position.x-50, y: lion.position.y+40)
            let feather = addSprite(location: featherLocation, depth: 4, spriteFile: "feather", physicsCategory: PhysicsCategory.None, collidesWith: PhysicsCategory.None, movability: unMovable, isCircular: false)
            self.feathers.append(feather)
            self.background.addChild(feather)
            
        }
        
    }
    
    func setApplePosition(Tree: SKSpriteNode, xRadius: Double, yRadius: Double, whichSide: Double, whichHeight: Double) -> Void{
        
        switch whichSide{
        case 0: //left side
            
            switch whichHeight{
                
            case 0: //lower part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: -xRadius, yRadius: -yRadius/2)
            case 1: //middle of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: -xRadius, yRadius: 0)
            case 2: //upper part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: -xRadius, yRadius: yRadius/2)
            default:
                break
                
            }
            
        case 1: //middle
            
            switch whichHeight{
                
            case 0: //lower part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: 0, yRadius: yRadius/2)
            case 1: //middle of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: 0, yRadius: yRadius)
            case 2: //upper part of the tree
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: 0, yRadius: 3*yRadius/2)
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
                self.makeApple(xPosition: Double(Tree.position.x), yPosition: Double(Tree.position.y), xRadius: xRadius, yRadius: 3*yRadius/2)
            default:
                break
                
            }   //end deadline handling
            
        default:
            break
        }
    }
    
    func makeApple(xPosition: Double, yPosition: Double, xRadius: Double, yRadius: Double){
        let apple = self.addSprite(xLocation: xPosition+xRadius, yLocation: yPosition+yRadius+Double(self.appleTree.size.height/6), spriteFile: "apple", depth: 3, physicsCategory: 0b101, collidesWith: 0b1111, movability: xyMovable, isCircular: true)
        self.background.addChild(apple)
        apples.append(apple)
        //applyGravity(objects: apples)
    }
    
    /*
     this function can be added to update to make the apples fall from the tree. The movablility in addSprite call in the makeApple method should be adjusted to yMovable.
     func applyGravity(objects: [SKSpriteNode]) -> Void{
        for object in objects{
            if object.position.y >= 50, object.name == yMovable{   //if the apple hasn't hit the ground
                object.position.y-=3.5    //make it hit the ground
            } else if object.position.y <= 50 {
                object.name = xyMovable
            }
        }
     }
     */
    
    func feathersFall(feathers: inout [SKSpriteNode]) -> Void {
        
        for feather in feathers {
            if feather.position.y >= 25 {   //if the feather hasn't hit the ground
                feather.position.y-=2.0    //make it hit the ground
                feather.alpha-=0.002
            } else if feather.position.y <= 25 || feather.alpha < 0 {
                if let index = feathers.index(of: feather) {
                    feathers.remove(at: index)
                }
                feather.removeFromParent()
            }
        }
    }
    
/*-----------------------------------------------------------------------------------------------------------------------------\\
     
                     ///////////////////////////////////////////////////////////////////////////////////////
                     ////////////////////////////////////// SPRITES ////////////////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////
     
\\-----------------------------------------------------------------------------------------------------------------------------*/
    
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
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Sun ) &&
            (secondBody.categoryBitMask == PhysicsCategory.Balloon)) {
            
            if let sun = firstBody.node as? SKSpriteNode, let
                balloon = secondBody.node as? SKSpriteNode {
                sunDidCollideWithBalloon(Sun: sun, Balloon: balloon)
            }
        }
        
        if((firstBody.categoryBitMask == PhysicsCategory.Apple) &&
            (secondBody.categoryBitMask == PhysicsCategory.horseMouth)){
            if let apple = firstBody.node as? SKSpriteNode {
                eat(eater: self.horse, eaterName: "horse", food: apple, foodName: "apple", gas: "fart")
            }
        }
        
        if((firstBody.categoryBitMask == PhysicsCategory.Chicken) &&
            (secondBody.categoryBitMask == PhysicsCategory.lionMouth)){
            if let chicken = firstBody.node as? SKSpriteNode{
                eat(eater: self.lion, eaterName: "lion", food: chicken, foodName: "chicken", gas: "burp")
            }
        }
        
    }
    
    func sunDidCollideWithBalloon(Sun: SKSpriteNode, Balloon: SKSpriteNode) {
        Balloon.removeFromParent()
        self.playSound("balloonburst")
    }

/*-----------------------------------------------------------------------------------------------------------------------------\\
     
     ///////////////////////////////////////////////////////////////////////////////////////
     ////////////////////////////// TAP AND SWIPE GESTURE HANDLING /////////////////////////
     ///////////////////////////////////////////////////////////////////////////////////////
     
\\-----------------------------------------------------------------------------------------------------------------------------*/
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            
            if !selectedNode.isEqual(touchedNode) {
                
                selectedNode.removeAllActions()
                selectedNode = touchedNode as! SKSpriteNode
                
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
    
    //calculates the new position of the dragged sprite (note, doesn't apply for unmovable objects)
    func panForTranslation(translation: CGPoint) {
        
        let position = selectedNode.position
        
        switch selectedNode.name! {
        case lightMovable:
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            switch Int((selectedNode.physicsBody?.categoryBitMask)!) {
            case 8: bulbLightNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            default : break
            }
        case animalMovable:
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y)
            
            switch selectedNode.physicsBody?.categoryBitMask {
            case PhysicsCategory.Lion?:
                lionMouth.position = CGPoint(x: lionMouth.position.x + translation.x, y: lionMouth.position.y)
                print("lion mouth moved")
            case PhysicsCategory.Horse?:
                horseMouth.position = CGPoint(x: horseMouth.position.x + translation.x, y: horseMouth.position.y)
                print("horse mouth moved")
            default:
                print("error: switch default in animalMovable")
            }
        case xMovable: selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y)
        case yMovable: selectedNode.position = CGPoint(x: position.x, y: position.y + translation.y)
        case xyMovable: selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        case unMovable: selectedNode.position = CGPoint(x: position.x, y: position.y)
            
        default:
            //          old code that enables background panning
            //let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            //background.position = self.boundLayerPos(aNewPosition: aNewPosition)
            print("error in movability switch")
        }
        
    }
    
    override func didMove(to view: SKView) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(recognizer:)))
        self.view!.addGestureRecognizer(gestureRecognizer)
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
    }
    
    //tap gesture handling
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
                
            case lionButton:
                if isLionThere {
                    isLionThere = false
                    lionButton.alpha = 1.0
                    lion.removeFromParent()
                    lionMouth.removeFromParent()
                    chickenCoop.removeFromParent()
                    feathers.removeAll()
                } else {
                    isLionThere = true
                    lionButton.alpha = 0.15
                    addChild(lion)
                    addChild(lionMouth)
                    addChild(chickenCoop)
                }
                
            case horseButton:
                if isHorseThere {
                    isHorseThere = false
                    horseButton.alpha = 1.0
                    horse.removeFromParent()
                    horseMouth.removeFromParent()
                    appleTree.removeFromParent()
                    apples.removeAll()
                } else {
                    isHorseThere = true
                    horseButton.alpha = 0.15
                    addChild(horse)
                    addChild(horseMouth)
                    addChild(appleTree)
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
                
            //
            case appleTree:
                
                if apples.count < 12 {
                    playSound("rustle")
                    
                    let when = DispatchTime.now() + 1
                    
                    DispatchQueue.main.asyncAfter(deadline: when) {  //after the sound has finished playing, create the apple
                        
                        let xRadius = Double(arc4random_uniform(300))
                        let yRadius = Double(arc4random_uniform(100))
                        let side = Double(arc4random_uniform(3))   //returns random number in range 0-2
                        let height = Double(arc4random_uniform(3))
                        
                        self.setApplePosition(Tree: self.appleTree, xRadius: xRadius, yRadius: yRadius, whichSide: side, whichHeight: height)
                        
                    }
                }
                break   //end appleTree case
                
                
            case chickenCoop:
                
                playSound("chickenSound")
                
                let when = DispatchTime.now() + 1
                
                DispatchQueue.main.asyncAfter(deadline: when) {
                    //randomizing location slightly
                    let xRadius = 25.0 - Double(arc4random_uniform(50))
                    let yRadius = 25.0 - Double(arc4random_uniform(50))
                    
                    let chicken = self.addSprite(xLocation: Double(self.chickenCoop.position.x + self.chickenCoop.size.width/2) + xRadius, yLocation: Double(self.chickenCoop.position.y - self.chickenCoop.size.height/5) + yRadius, spriteFile: "chicken", depth: 2, physicsCategory: PhysicsCategory.Chicken, collidesWith: 0b10000, movability: xyMovable, isCircular: false)
                    self.background.addChild(chicken)
                }
                break
                
            default: break //no error case because a tap gesture on any objects not covered is perfectly legal
            }
        }
    }
    
    /* old code that allows for background panning
     func boundLayerPos(aNewPosition: CGPoint) -> CGPoint {
     
     let winSize = self.size
     var retval = aNewPosition
     retval.x = CGFloat(min(retval.x, 0))
     retval.x = CGFloat(max(retval.x, -(background.size.width) + winSize.width))
     retval.y = self.position.y
     return retval
     
     }
     */
    
/*-----------------------------------------------------------------------------------------------------------------------------\\
     
                     ///////////////////////////////////////////////////////////////////////////////////////
                     ///////////////////////////////// SWIFT SCENE NECESSITIES /////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////
     
\\-----------------------------------------------------------------------------------------------------------------------------*/
    
    //called once to initialize the scene
    override init(size: CGSize) {
        super.init(size: size)
        loadSprites()
    }
    
    func createSceneContents() {
        self.scaleMode = .aspectFit
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
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
    
    //called every timestep (very very often)
    override func update(_ currentTime: TimeInterval) {
        //applyGravity(objects: apples)
        feathersFall(feathers: &feathers)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
