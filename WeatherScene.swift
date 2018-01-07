/*
WeatherScene.swift
ECE-iOS application
Created by ECE on 10/26/17.
Copyright © 2017 ECE. All rights reserved.
*/

import SpriteKit
import AVFoundation

private let xMovable = "xMovable"
private let yMovable = "yMovable"
private let xyMovable = "xyMovable"
private let unMovable = "unMovable"
private let skyMovable = "skyMovable"



class WeatherScene: SKScene, SKPhysicsContactDelegate {
    
    let lakeZone = Zone(leftCoord: 0, rightCoord: 255)
    let rainZone = Zone(leftCoord: 256, rightCoord: 511)
    let hailZone = Zone(leftCoord: 512, rightCoord: 767)
    let snowZone = Zone(leftCoord: 768, rightCoord: 1023)
    
    var background = SKSpriteNode(imageNamed: "plainBackground")
    var menuButton = SKSpriteNode(imageNamed: "menuButton")
    var selectedNode = SKSpriteNode()
    var precipitationObjects: [SKSpriteNode] = []
    var skyObjects: [SKSpriteNode] = []
    var rainPlayer = AVAudioPlayer()
    var hailPlayer = AVAudioPlayer()
    var thunderPlayer = AVAudioPlayer()
    var playSnowSound = false
    var playHailSound = false
    var playRainSound = false
    var hasStormed = false
    var shouldItRain = 1

/*
     
     
    
//-----------------------------------------------------------------------------------------------------------------------------\\
    
                    ///////////////////////////////////////////////////////////////////////////////////////
                    /////////////////////////////////////// SPRITES ///////////////////////////////////////
                    ///////////////////////////////////////////////////////////////////////////////////////
    
\\-----------------------------------------------------------------------------------------------------------------------------//
     
     
     
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
    
    //Creates a sprite based off the location of another sprite
    func addSprite(location: CGPoint, zPosition: Double, spriteFile: String, physicsCategory: UInt32, collidesWith: UInt32, movability: String, isCircular: Bool) -> SKSpriteNode {
        
        let sprite = SKSpriteNode(imageNamed: spriteFile)
        sprite.name = movability
        sprite.position = location
        
        if (isCircular) {
            
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: max(sprite.size.width/2,sprite.size.height/2)) // 1
            
        }
        
        else {
            
            sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size) // 1
            
        }
        
        sprite.physicsBody?.isDynamic = true // 2
        sprite.physicsBody?.categoryBitMask = physicsCategory // 3
        sprite.physicsBody?.contactTestBitMask = collidesWith // 4
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        return sprite
        
    }
    
    //Called when the scene is first loaded, this adds the background image and the sun to the view
    func loadSprites() -> Void {
        
        self.background.anchorPoint = CGPoint(x: 0, y: 0)
        self.background.position = CGPoint(x: 0, y: 0)
        self.background.zPosition = -1      //don't want the background to get in the way of any other sprites
        self.background.name = unMovable
        addChild(background)
        
        let sun = addSprite(xLocation: 688, yLocation: 600, zPosition: 1, spriteFile: "sun", physicsCategory: 0b11, collidesWith: 0, movability: skyMovable, isCircular: true)
        background.addChild(sun)
        skyObjects.append(sun)
        
        menuButton.position = CGPoint(x: 1000, y: 744)
        menuButton.zPosition = 1
        menuButton.name = unMovable
        menuButton.alpha = 0.15
        background.addChild(menuButton)
        
    } /*
     
     
     
//-----------------------------------------------------------------------------------------------------------------------------\\

                     ///////////////////////////////////////////////////////////////////////////////////////
                     ///////////////////////////////// LOCATION HANDLING ///////////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////
    
\\-----------------------------------------------------------------------------------------------------------------------------//
     
 
    
    //Checks the location of the given sprite and returns which zone it lies in */
    func whereIsTheWeather(weather: SKSpriteNode) -> precipitation {
        
        switch Int(weather.position.x) {
            
        case lakeZone.leftCoord..<lakeZone.rightCoord:      //syntax indicates if weather.position.x is between the given
            return .lake
        case snowZone.leftCoord..<snowZone.rightCoord:
            return .snow
        case hailZone.leftCoord..<hailZone.rightCoord:
            return .hail
        case rainZone.leftCoord..<rainZone.rightCoord:
            return .rain
        default:
            return .outOfZone
            
        }
        
    }
    
    func cloudIsCreating() -> Bool {
        
        var createCloud = false
        
        if whereIsTheWeather(weather: skyObjects[0]) == .lake && skyObjects.count <= 4 {
            
            for skyObject in skyObjects {
                
                if skyObject.physicsBody?.categoryBitMask == 0b10 && skyObject.position.x <= 128 && skyObject.position.y < 600 {
                    
                    createCloud = true
                    
                }
            }
       
        } else {
            
            createCloud = true
            
        }
        
        return createCloud
        
    }
    
    func cloudsRain() -> Void {
        
        //Rain a bit slower
        if shouldItRain % 10 == 0 {
            
            shouldItRain = 1
        
            for skyObject in skyObjects {
                
                let precipitationType = whereIsTheWeather(weather: skyObject)
                
                if skyObject.physicsBody?.categoryBitMask == 0b10 && skyObject.alpha > 0 && (precipitationType == .snow || precipitationType == .rain || precipitationType == .hail) {
                    
                    let leftTime = DispatchTime.now() + 0.025
                    let midTime = DispatchTime.now() + 0.05
                    let rightTime = DispatchTime.now() + 0.075
                    
                    //Divide the cloud into sections and create precipitation in each section (at a random location)
                    let radius = UInt32(15) + arc4random_uniform(UInt32(25))
                    
                    let precipLeftSide = UInt32(skyObject.position.x) - radius
                    let precipMiddle = UInt32(skyObject.position.x)
                    let precipRightSide = UInt32(skyObject.position.x) + radius

                    DispatchQueue.main.asyncAfter(deadline: leftTime){
                        let precipitationLeft = self.addSprite(xLocation: Double(precipLeftSide), yLocation: Double(skyObject.position.y-75), zPosition: 2, spriteFile: "steady-"+precipitationType.rawValue, physicsCategory: 0b110, collidesWith: 0, movability: unMovable, isCircular: true)
                        self.background.addChild(precipitationLeft)
                        self.precipitationObjects.append(precipitationLeft)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: midTime){
                        let precipitationMid = self.addSprite(xLocation: Double(precipMiddle), yLocation: Double(skyObject.position.y-75), zPosition: 2, spriteFile: "steady-"+precipitationType.rawValue, physicsCategory: 0b110, collidesWith: 0, movability: unMovable, isCircular: true)
                        self.background.addChild(precipitationMid)
                        self.precipitationObjects.append(precipitationMid)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: rightTime){
                        let precipitationRight = self.addSprite(xLocation: Double(precipRightSide), yLocation: Double(skyObject.position.y-75), zPosition: 2, spriteFile: "steady-"+precipitationType.rawValue, physicsCategory: 0b110, collidesWith: 0, movability: unMovable, isCircular: true)
                        self.background.addChild(precipitationRight)
                        self.precipitationObjects.append(precipitationRight)
                    }
                    
                    skyObject.alpha -= 0.02     //as the cloud precipitates, it will start to fade
                    
                }
            
            }
            
        } else {
            
            shouldItRain+=1
        
        }
        
    }
    
    /*
    
//-----------------------------------------------------------------------------------------------------------------------------\\
     
                      ///////////////////////////////////////////////////////////////////////////////////////
                      ////////////////////////////////// WEATHER ACTIONS ////////////////////////////////////
                      ///////////////////////////////////////////////////////////////////////////////////////
     
\\-----------------------------------------------------------------------------------------------------------------------------//
    
 
 
    //Changes the cloud's opacity and height as it forms */
    func formCloud(cloud: SKSpriteNode) -> Void {
        
        cloud.alpha += 0.0025
        cloud.position.y += 2.5
        
    }
    
    //Makes the precipitation fall, and removes it when it hits the ground
    func precipFalls() -> Void {
        
        var rainCount = 0, hailCount = 0    //used to count how much rain or hail is on the screen
        
        for precipitation in precipitationObjects {
            
            precipitation.position.y -= 6
            
            if whereIsTheWeather(weather: precipitation) == .rain { //if it's a raindrop, add it to the rain count
                
                rainCount+=1
                
            } else if whereIsTheWeather(weather: precipitation) == .hail {
                
                hailCount+=1
                
            }
            
            if precipitation.position.y < 100 {     //removes the precipitation when it hits the ground
                
                if whereIsTheWeather(weather: precipitation) == .rain {
                    
                    rainCount -= 1  //decrement the rain count when the drop hits the ground
                    
                } else if whereIsTheWeather(weather: precipitation) == .hail {
                    
                    hailCount -= 1
              
                }
                
                precipitation.removeFromParent()
                
            }
            
        }
        
        //If it's raining but the rain sound isn't playing
        if rainCount > 0 && playRainSound == false {
            
            playRainSound = true
            //playSound("rainSound")
            if playHailSound == false { UIScreen.main.brightness = CGFloat(0.8) }
            
        } else if rainCount == 0 && playRainSound == true { //If it's not raining but the sound is still playing
            
            playRainSound = false
            //rainPlayer.stop()
            if playHailSound == false { UIScreen.main.brightness = CGFloat(1.0) }
        }

        if hailCount > 0 && playHailSound == false {
            
            playHailSound = true
            //playSound("hailSound")
            if playRainSound == false { UIScreen.main.brightness = CGFloat(0.8) }
            
        } else if hailCount == 0 && playHailSound == true {
            
            playHailSound = false
            //hailPlayer.stop()
            if playRainSound == false { UIScreen.main.brightness = CGFloat(1.0) }
            
        }
        
    }
    
    //Called every frame, this function begins cloud formation if there are any clouds to be formed
    func checkCloudFormation() -> Void {
        
        //If the sun is over the lake and a cloud isn't being made, make a cloud and begin forming it
        if cloudIsCreating() == false && whereIsTheWeather(weather: skyObjects[0]) == .lake{
            
            let cloudLocation = arc4random_uniform(UInt32(25)) + UInt32(102.5)
            
            let cloud = addSprite(xLocation: Double(cloudLocation), yLocation: 100, zPosition: 2, spriteFile: "cloud", physicsCategory: 0b10, collidesWith: 0, movability: skyMovable, isCircular: true)
            cloud.alpha = 0     //cloud is holding no water to begin with
            background.addChild(cloud)
            skyObjects.append(cloud)
                
            formCloud(cloud: cloud)
            
        }
        
        //If there are still clouds to be formed while the sun is over the lake zone
        if skyObjects.count > 1 {
            
            for skyObject in skyObjects {
                
                //If the cloud is over the lake and it hasn't fully formed
                if whereIsTheWeather(weather: skyObject) == .lake && skyObject.physicsBody?.categoryBitMask == 0b10 {
                    
                    //Not yet in the sky and still not fully opaque
                    if skyObject.position.y <= 600 && skyObject.alpha <= 1 && whereIsTheWeather(weather: skyObjects[0]) == .lake {

                        formCloud(cloud: skyObject)
                        
                    }
                        
                    //If it reaches the sky but is not yet fully opaque, make it more opaque (as long as the sun is there)
                    else if skyObject.position.y >= 600 && whereIsTheWeather(weather: skyObjects[0]) == .lake {
                        
                        //cloudIsCreating = false
                        
                        if skyObject.alpha < 1 {
                            
                            skyObject.alpha += 0.0025
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    func startStorm(zone: precipitation) {
        
        hasStormed = true
        var cloudStormed = false
        for cloud in skyObjects {
            
            if cloud.physicsBody?.categoryBitMask == 0b10 {
                if whereIsTheWeather(weather: cloud) == zone && cloudStormed == false {
                    
                    cloudStormed = true
                    zapThenBoom(cloud: cloud, lightningStarts: DispatchTime.now())
                    
                } else if whereIsTheWeather(weather: cloud) == zone && cloudStormed == true {
                    
                    cloudStormed = false
                    zapThenBoom(cloud: cloud, lightningStarts: DispatchTime.now()+0.5)
                    
                }
                
            }
            
        }
    }
    
    func cloudsLeft(precipZone: precipitation) -> Int {
        var rainClouds = 0
        var hailClouds = 0
        var snowClouds = 0
        
        for cloud in skyObjects {
            
            if cloud.physicsBody?.categoryBitMask == 0b10 {
                
                switch whereIsTheWeather(weather: cloud) {
                case .snow : snowClouds+=1
                break;
                case .hail : hailClouds+=1
                break;
                case .rain : rainClouds+=1
                break;
                case .lake : break;
                case .outOfZone : break;
                }
                
            }
        }
        switch precipZone {
            case .snow : return snowClouds
            case .hail : return hailClouds
            case .rain : return rainClouds
            case .lake : return -1
            case .outOfZone : return -1
        }
    }
    
    func thunderAndLightning() -> Void {
        if hasStormed == false {
            
            var rainClouds = 0
            var hailClouds = 0
            var snowClouds = 0
            
            for cloud in skyObjects {
                
                if cloud.physicsBody?.categoryBitMask == 0b10 {
                    
                    switch whereIsTheWeather(weather: cloud) {
                    case .snow : snowClouds+=1
                    break;
                    case .hail : hailClouds+=1
                    break;
                    case .rain : rainClouds+=1
                    break;
                    case .lake : break;
                    case .outOfZone : break;
                    }
                    
                }
            }
                if rainClouds >= 2 {
                   startStorm(zone: .rain)
                }
                
                if hailClouds >= 2 {
                    startStorm(zone: .hail)
                }
                
                if snowClouds >= 2 {
                    
                   startStorm(zone: .snow)
                }
                
            
        }
    }
    
    func zapThenBoom(cloud: SKSpriteNode, lightningStarts: DispatchTime) {
        
        let firstFlash = lightningStarts
        let firstFlashEnds = lightningStarts + 0.3
        let secondFlash = lightningStarts + 1.5
        let secondFlashEnds = lightningStarts + 1.8
        let stormAgain = lightningStarts + 7
        
        let lightning = addSprite(xLocation: Double(cloud.position.x), yLocation: Double(cloud.position.y-100), zPosition: 0.0, spriteFile: "lightning", physicsCategory: 0b111, collidesWith: 0, movability: unMovable, isCircular: false)
        
        DispatchQueue.main.asyncAfter(deadline: firstFlash){
            self.background.addChild(lightning)
            //self.playSound("thunderSound")
        }
        DispatchQueue.main.asyncAfter(deadline: firstFlashEnds){
            lightning.removeFromParent()
        }
        DispatchQueue.main.asyncAfter(deadline: secondFlash){
            self.background.addChild(lightning)
        }
        DispatchQueue.main.asyncAfter(deadline: secondFlashEnds){
            lightning.removeFromParent()
        }
        DispatchQueue.main.asyncAfter(deadline: stormAgain){
            self.hasStormed = false
        }
    }
    //Goes through all of the clouds on the screen and removes the ones that are transparent
    func deleteClouds() -> Void {
        
        var counter = 0

        for skyObject in skyObjects {
            
            //Performs cloud cleanup. Note that checking the alpha value precludes inclusion of the sun (sun's alpha value is 1)
            if skyObject.alpha <= 0 {
                
                skyObject.removeFromParent()
                skyObjects.remove(at: counter)
                
            }
            
            counter += 1
            
        }
        
    } /*
     
     
     
//-----------------------------------------------------------------------------------------------------------------------------\\
     
                     ///////////////////////////////////////////////////////////////////////////////////////
                     //////////////////////////////// GESTURES AND COLLISION ///////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////
     
\\-----------------------------------------------------------------------------------------------------------------------------//
     
    
     
    //  */
    override func didMove(to view: SKView) {
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(recognizer:)))
        self.view!.addGestureRecognizer(gestureRecognizer)
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            
            if !selectedNode.isEqual(touchedNode) {
                
                selectedNode.removeAllActions()
                selectedNode = touchedNode as! SKSpriteNode
                
            }
            
        }
        
    }
    
    //Drag and drop code
    func panForTranslation(translation: CGPoint) {
        
        let position = selectedNode.position
        
        if selectedNode.name! == skyMovable {      //for the sun and clouds
            
            if position.y + translation.y > 600 && position.y + translation.y < 700  && position.x + translation.x < 900 && position.x + translation.x > 35 {
                
                selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                
            }
                
            else {
                
                if position.x + translation.x < 900 && position.x + translation.x > 35 {
                    
                    selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y)
                    
                }
            }
            
        }
            
        else if selectedNode.name! == unMovable {
            
            selectedNode.position = CGPoint(x: position.x, y: position.y)
            
        }
            
        else {
            
            let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            background.position = self.boundLayerPos(aNewPosition: aNewPosition)
            
        }
        
    }

    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began {
            
            var touchLocation = recognizer.location(in: recognizer.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            self.selectNodeForTouch(touchLocation: touchLocation)
            
        }
        
        else if recognizer.state == .changed {
            
            var translation = recognizer.translation(in: recognizer.view!)
            translation = CGPoint(x: translation.x, y: -translation.y)
            self.panForTranslation(translation: translation)
            recognizer.setTranslation(CGPoint(x: 0,y: 0), in: recognizer.view)

        }
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == menuButton {
                
                if let view = view {
                    
                    let transition:SKTransition = SKTransition.fade(withDuration: 3)
                    let scene:SKScene = MenuScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                
                }
            
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
        
    } /*
     
     
     
//-----------------------------------------------------------------------------------------------------------------------------\\
     
                     ///////////////////////////////////////////////////////////////////////////////////////
                     ///////////////////////////////////// MISCELLANEOUS ///////////////////////////////////
                     ///////////////////////////////////////////////////////////////////////////////////////
     
\\-----------------------------------------------------------------------------------------------------------------------------//
   
    
    
    // */
    func playSound(_ soundFile: String) {
        
        
        let soundPath = Bundle.main.path(forResource: "Sounds/" + soundFile, ofType:"wav")!
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if soundFile == "rainSound" {
               
                rainPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                //guard let player = player else {return}
                rainPlayer.prepareToPlay()
                rainPlayer.play()
                
            } else if soundFile == "hailSound" {
               
                hailPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                //guard let player = player else {return}
                hailPlayer.prepareToPlay()
                hailPlayer.play()
                
            } else if soundFile == "thunderSound" {
                
                thunderPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                //guard let player = player else {return}
                thunderPlayer.prepareToPlay()
                thunderPlayer.play()
                
            } else if rainPlayer == nil || hailPlayer == nil || thunderPlayer == nil{
                
                print("error")
                
            }
            
        } catch let error {
            
            print(error.localizedDescription)
            
       }
    
    }
     
    //Called every frame, this method performs checks to see if there are any dispelled clouds to remove, as well as checks
    //to see if there's any precipitation to be moved
    override func update(_ currentTime: TimeInterval) {
        
        checkCloudFormation()
        cloudsRain()
        precipFalls()
        deleteClouds()
        thunderAndLightning()
        
        
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        loadSprites()   //load the background and sun when the scene initializes
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }

}
