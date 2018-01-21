/*
 WeatherScene.swift
 ECE-iOS application
 Created by ECE on 10/26/17.
 Copyright © 2017 ECE. All rights reserved.
 */

import SpriteKit
import AVFoundation
import Foundation

/*-----------------------------------------------------------------------------------------------------------------------------\\
 
                    ///////////////////////////////////////////////////////////////////////////////////////
                    ///////////////////////////////////// INITIALIZING ////////////////////////////////////
                    ///////////////////////////////////////////////////////////////////////////////////////
 
 \\-----------------------------------------------------------------------------------------------------------------------------*/

private let xMovable = "xMovable"
private let yMovable = "yMovable"
private let xyMovable = "xyMovable"
private let unMovable = "unMovable"
private let skyMovable = "skyMovable"

struct hZone {
    
    let leftCoord : Int
    let rightCoord : Int
    
}

struct vZone {
    
    let lowerCoord : Int
    let upperCoord : Int
    
}

struct altitudeMap {
    
    let altitudeZone1 : hZone
    let altitude1 : Int
    let altitudeZone2 : hZone
    let altitude2 : Int
    let altitudeZone3 : hZone
    let altitude3 : Int
    let altitudeZone4 : hZone
    let altitude4 : Int
    let altitudeZone5 : hZone
    let altitude5 : Int
    let altitudeZone6 : hZone
    let altitude6 : Int
    
    init() {
        
        altitudeZone1 = hZone(leftCoord: 0, rightCoord: 230)
        altitude1 = 210
        altitudeZone2 = hZone(leftCoord: 231, rightCoord: 445)
        altitude2 = 266
        altitudeZone3 = hZone(leftCoord: 446, rightCoord: 562)
        altitude3 = 240
        altitudeZone4 = hZone(leftCoord: 563, rightCoord: 680)
        altitude4 = 290
        altitudeZone5 = hZone(leftCoord: 681, rightCoord: 765)
        altitude5 = 200
        altitudeZone6 = hZone(leftCoord: 766, rightCoord: 1024)
        altitude6 = 210
    }
    
}

enum precipitation : String {
    
    case rain
    case hail
    case snow
    case lake
    case outOfZone
    
}

class WeatherScene2: SKScene, SKPhysicsContactDelegate {
    
    let lakeZone = vZone(lowerCoord: 0, upperCoord: 1)
    let rainZone = vZone(lowerCoord: 2, upperCoord: 426)
    let hailZone = vZone(lowerCoord: 427, upperCoord: 594)
    let snowZone = vZone(lowerCoord: 595, upperCoord: 760)
    
    let altitudeZone1 = hZone(leftCoord: 0, rightCoord: 230)
    let altitudeZone2 = hZone(leftCoord: 231, rightCoord: 445)
    let altitudeZone3 = hZone(leftCoord: 446, rightCoord: 562)
    let altitudeZone4 = hZone(leftCoord: 563, rightCoord: 680)
    let altitudeZone5 = hZone(leftCoord: 681, rightCoord: 765)
    let altitudeZone6 = hZone(leftCoord: 766, rightCoord: 1024)
    
    var backgroundMap = altitudeMap()
    
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
    var precipFallsCheck = 1
    
     /*-----------------------------------------------------------------------------------------------------------------------------\\
     
                        ///////////////////////////////////////////////////////////////////////////////////////
                        /////////////////////////////////////// SPRITES ///////////////////////////////////////
                        ///////////////////////////////////////////////////////////////////////////////////////
     
     \\-----------------------------------------------------------------------------------------------------------------------------*/
    
     //Creates and returns a sprite based on X and Y coordinates (Doubles)
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
    
    //Creates and returns a sprite based off the location of another sprite
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
        
        UIScreen.main.brightness = CGFloat(1.0)
        
        menuButton.position = CGPoint(x: 1000, y: 744)
        menuButton.zPosition = 1
        menuButton.name = unMovable
        menuButton.alpha = 0.15
        background.addChild(menuButton)
        
    }
    
     /*-----------------------------------------------------------------------------------------------------------------------------\\
     
                        ///////////////////////////////////////////////////////////////////////////////////////
                        ///////////////////////////////// LOCATION HANDLING ///////////////////////////////////
                        ///////////////////////////////////////////////////////////////////////////////////////
     
     \\-----------------------------------------------------------------------------------------------------------------------------*/
    
     //Checks the location of the given sprite and returns which zone it lies in
    func whereIsTheWeather(weather: SKSpriteNode) -> precipitation {
        
        switch Int(weather.position.y) {
            
        case lakeZone.lowerCoord..<lakeZone.upperCoord:      //syntax indicates if weather.position.x is in the given zone
            return .lake
        case snowZone.lowerCoord..<snowZone.upperCoord:
            return .snow
        case hailZone.lowerCoord..<hailZone.upperCoord:
            return .hail
        case rainZone.lowerCoord..<rainZone.upperCoord:
            return .rain
        default:
            return .outOfZone
            
        }
        
    }
    
    func isThereWeather(weather: SKSpriteNode) -> Bool {
        
        if Int(weather.position.x) < 200 { return false } //no weather in lake zone
        else {return true}
        
    }
    
    func cloudIsCreating() -> Bool {
        
        var createCloud = false
        
        if isThereWeather(weather: skyObjects[0]) == false && skyObjects.count <= 4 {   //if the sun is in the lake zone
            
            weatherLoop: for skyObject in skyObjects {
                
                if skyObject.physicsBody?.categoryBitMask == 0b10 && skyObject.position.x <= 128 && skyObject.position.y < 600 {
                    
                    createCloud = true
                    
                }
                
                if createCloud { break weatherLoop }
                
            }
            
        } else {
            
            createCloud = true
            
        }
        
        return createCloud
        
    }
    
     /*-----------------------------------------------------------------------------------------------------------------------------\\
     
                        ///////////////////////////////////////////////////////////////////////////////////////
                        //////////////////////////////// WEATHER ACTIONS //////////////////////////////////////
                        ///////////////////////////////////////////////////////////////////////////////////////
     
     \\-----------------------------------------------------------------------------------------------------------------------------*/
    
     /********************************************************* CLOUDS **************************************************************/
    
    // if the sun is over the lake, the given cloud is formed.
    func lakeEvaporatesIntoClouds(cloud: SKSpriteNode) {
        
        //If the cloud is over the lake and it's definitely a cloud
        if isThereWeather(weather: cloud) == false && cloud.physicsBody?.categoryBitMask == 0b10 {
            
            //Not yet in the sky, still not fully opaque, and the sun is over the lake
            if cloud.position.y <= 600 && cloud.alpha <= 1 && isThereWeather(weather: skyObjects[0]) == false {
                
                fillCloud(cloud: cloud)
                
            }
                
                //If it reaches the sky but is not yet fully opaque, make it more opaque (as long as the sun is there)
            else if cloud.position.y >= 600 && isThereWeather(weather: skyObjects[0]) == false {
                
                if cloud.alpha < 1 {
                    
                    cloud.alpha += 0.0025
                    
                }
                
            }
            
        }
        
    }
    
    //Changes the cloud's opacity and height as it forms
    func fillCloud(cloud: SKSpriteNode) -> Void {
        
        cloud.alpha += 0.0025
        cloud.position.y += 2.5
        
    }
    
    //If the sun is over the lake and a cloud isn't being made, make a cloud and begin filling it, this function begins cloud formation if there are any clouds to be formed
    func formCloud() -> Void {
        
        if cloudIsCreating() == false && isThereWeather(weather: skyObjects[0]) == false{
            
            let cloudLocation = arc4random_uniform(UInt32(25)) + UInt32(102.5)
            
            let cloud = addSprite(xLocation: Double(cloudLocation), yLocation: 100, zPosition: 2, spriteFile: "cloud", physicsCategory: 0b10, collidesWith: 0, movability: skyMovable, isCircular: true)
            cloud.alpha = 0     //cloud is holding no water to begin with
            background.addChild(cloud)
            skyObjects.append(cloud)
            
            fillCloud(cloud: cloud)
            
        }
        
    }
    
    func cloudsPrecipitate() -> Void {
        
        formCloud()
        thunderAndLightning()
        
        var counter = 0 // to be used to index through skyObjects
        
        for skyObject in skyObjects {
            
            lakeEvaporatesIntoClouds(cloud: skyObject)
            
            if shouldItRain % 20 == 0 { //Rain a bit slower
                
                //if it's a cloud and its alpha value is above 0 and its not over the lake, in other words, if this cloud will precipitate
                if skyObject.physicsBody?.categoryBitMask == 0b10 && skyObject.alpha > 0 && isThereWeather(weather: skyObject) {
                    
                    let precipitationType = whereIsTheWeather(weather: skyObject)
                    var precipCategory = UInt32()
                    
                    switch precipitationType {
                        
                    case .rain: precipCategory = 0b110
                    break;
                    case .hail: precipCategory = 0b1001
                    break;
                    case .snow: precipCategory = 0b1010
                    break;
                    default:
                        break;
                        
                    }
                    
                    thisCloudRains(cloud: skyObject, precipType: precipitationType.rawValue, counter: counter, precipCategory: precipCategory)
                    
                }
                
                counter += 1
                
            } // end shouldItRain if
            
        } // end for
        
        shouldItRain+=1
        //shouldItRain%=10
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
        
    }
    
     /****************************************************** PRECIPITATION ***********************************************************/
    
    // spawns precipitation of the given type and category under the given cloud, and deletes the cloud if it's alpha has decreased below 0
    func thisCloudRains(cloud: SKSpriteNode, precipType: String, counter: Int, precipCategory: UInt32) {
        
        let leftTime = DispatchTime.now() + 0.025
        let midTime = DispatchTime.now() + 0.05     //Three staggered timers
        let rightTime = DispatchTime.now() + 0.075
        
        //Divide the cloud into sections and create precipitation in each section (at a random location)
        let radius = UInt32(15) + arc4random_uniform(UInt32(25))
        
        let precipLeftSide = UInt32(cloud.position.x) - radius
        let precipMiddle = UInt32(cloud.position.x)     //Three staggered positions under the cloud
        let precipRightSide = UInt32(cloud.position.x) + radius
        
        DispatchQueue.main.asyncAfter(deadline: leftTime){
            let precipitationLeft = self.addSprite(xLocation: Double(precipLeftSide), yLocation: Double(cloud.position.y), zPosition: 1, spriteFile: "steady-"+precipType, physicsCategory: UInt32(precipCategory), collidesWith: 0, movability: unMovable, isCircular: true)
            self.background.addChild(precipitationLeft)
            self.precipitationObjects.append(precipitationLeft)
        }
        
        DispatchQueue.main.asyncAfter(deadline: midTime){   //Three timer methods staggered by timers.
            let precipitationMid = self.addSprite(xLocation: Double(precipMiddle), yLocation: Double(cloud.position.y), zPosition: 1, spriteFile: "steady-"+precipType, physicsCategory: UInt32(precipCategory), collidesWith: 0, movability: unMovable, isCircular: true)
            self.background.addChild(precipitationMid)
            self.precipitationObjects.append(precipitationMid)
        }
        
        DispatchQueue.main.asyncAfter(deadline: rightTime){
            let precipitationRight = self.addSprite(xLocation: Double(precipRightSide), yLocation: Double(cloud.position.y), zPosition: 1, spriteFile: "steady-"+precipType, physicsCategory: UInt32(precipCategory), collidesWith: 0, movability: unMovable, isCircular: true)
            self.background.addChild(precipitationRight)
            self.precipitationObjects.append(precipitationRight)
        }
        
        //as the cloud precipitates, it will start to fade
        cloud.alpha -= 0.02
        if cloud.alpha <= 0 {
            
            cloud.removeFromParent()
            skyObjects.remove(at: counter)
            
        }
        
    }
    
    //Makes the precipitation fall, and removes it when it hits the ground
    func precipFalls() -> Void {
        
        var rainCount = 0.0, hailCount = 0.0    //used to count how much rain or hail is on the screen
        
        for precipitation in precipitationObjects {
            
            precipitation.position.y -= 3 // gravity - John Mayer
            
            let precipType = whereIsTheWeather(weather: precipitation)
            
            // switching precipitation types as precipitation falls down screen
            if precipType == .rain { //if it's a raindrop, add it to the rain count
                
                rainCount+=1
                
                if precipitation.physicsBody?.categoryBitMask != 0b110 { // if not a raindrop but in the rain zone
                    
                    //add hail
                    let newRain = addSprite(location: precipitation.position, zPosition: 2, spriteFile: "steady-rain", physicsCategory: 0b110, collidesWith: 0, movability: unMovable, isCircular: true)
                    addChild(newRain)           //Create and append a raindrop and delete the imposter.
                    self.precipitationObjects.append(newRain)
                    
                    //remove imposter
                    precipitation.removeFromParent()
                    hailCount-=1
                    if let index = precipitationObjects.index(of: precipitation) {
                        precipitationObjects.remove(at: index)
                    }
                    
                } else { // if it is a raindrop in the rainzone
                    
                    precipLands(precipitation: precipitation, precipCount: &rainCount, isItSnow: false)
                    
                } //end bitmask if
                
            } else if precipType == .hail { // if its in the hail zone
                
                hailCount+=1
                
                if precipitation.physicsBody?.categoryBitMask != 0b1001 { // but its not hail
                    
                    //add hail
                    let newHail = addSprite(location: precipitation.position, zPosition: 2, spriteFile: "steady-hail", physicsCategory: 0b1001, collidesWith: 0, movability: unMovable, isCircular: true)
                    addChild(newHail)
                    self.precipitationObjects.append(newHail)
                    print(newHail.position)
                    
                    //remove imposter
                    precipitation.removeFromParent()
                    if let index = precipitationObjects.index(of: precipitation) {
                        precipitationObjects.remove(at: index)
                    }
                    
                } else { // if it is hail
                    
                    precipLands(precipitation: precipitation, precipCount: &hailCount, isItSnow: false)
                    
                } // end bitmask if
                
            } else if precipType == .snow {
                
                precipLands(precipitation: precipitation, precipCount: &hailCount, isItSnow: false)
                
            } //end precipType if
            
        } //end precipObjects for
        
        precipSounds(rainCount: rainCount, hailCount: hailCount)
        
    }
    
    func precipLands(precipitation: SKSpriteNode, precipCount: inout Double, isItSnow: Bool) -> Void {
        
        switch Int(precipitation.position.x) { // precipitation hits the ground at varying altitudes over the landscape
            
        case backgroundMap.altitudeZone1.leftCoord ..< backgroundMap.altitudeZone1.rightCoord : // flatGround
            
            if Int(precipitation.position.y) < backgroundMap.altitude1, let index = precipitationObjects.index(of: precipitation) {
                precipitation.removeFromParent()
                precipitationObjects.remove(at: index)
                if isItSnow {  /* precipCount += .01 */ } else {
                    precipCount-=1
                }
            }
            
        case backgroundMap.altitudeZone2.leftCoord ..< backgroundMap.altitudeZone2.rightCoord: // footHills
            
            if Int(precipitation.position.y) < backgroundMap.altitude2, let index = precipitationObjects.index(of: precipitation) {
                precipitation.removeFromParent()
                precipitationObjects.remove(at: index)
                if isItSnow {  /* precipCount += .01 */ } else {
                    precipCount-=1
                }
            }
            
        case backgroundMap.altitudeZone3.leftCoord ..< backgroundMap.altitudeZone3.rightCoord: // mountains
            
            if Int(precipitation.position.y) < backgroundMap.altitude3, let index = precipitationObjects.index(of: precipitation) {
                precipitation.removeFromParent()
                precipitationObjects.remove(at: index)
                if isItSnow {  /* precipCount += .01 */ } else {
                    precipCount-=1
                }
            }
            
        case backgroundMap.altitudeZone4.leftCoord ..< backgroundMap.altitudeZone4.rightCoord: // summit
            
            if Int(precipitation.position.y) < backgroundMap.altitude4, let index = precipitationObjects.index(of: precipitation) {
                precipitation.removeFromParent()
                precipitationObjects.remove(at: index)
                if isItSnow {  /* precipCount += .01 */ } else {
                    precipCount-=1
                }
            }
            
        case backgroundMap.altitudeZone5.leftCoord ..< backgroundMap.altitudeZone5.rightCoord: // summit
            
            if Int(precipitation.position.y) < backgroundMap.altitude5, let index = precipitationObjects.index(of: precipitation) {
                precipitation.removeFromParent()
                precipitationObjects.remove(at: index)
                if isItSnow {  /* precipCount += .01 */ } else {
                    precipCount-=1
                }
            }
            
        case backgroundMap.altitudeZone6.leftCoord ..< backgroundMap.altitudeZone6.rightCoord: // summit
            
            if Int(precipitation.position.y) < backgroundMap.altitude6, let index = precipitationObjects.index(of: precipitation) {
                precipitation.removeFromParent()
                precipitationObjects.remove(at: index)
                if isItSnow {  /* precipCount += .01 */ } else {
                    precipCount-=1
                }
            }
            
            
        default:
            print("error, default case in precipFalls hit")
            break;
        }
        
    }
    
     /********************************************************* STORMS **************************************************************/
    
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
    
    func thunderAndLightning() -> Void {
        
        if hasStormed == false && skyObjects.count > 2{
            
            var rainClouds = 0
            var hailClouds = 0
            var snowClouds = 0
            
            for index in 1...skyObjects.count-1 {
                
                if isThereWeather(weather: skyObjects[index]) {
                    
                    switch whereIsTheWeather(weather: skyObjects[index]) {
                        
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
     
     /*-----------------------------------------------------------------------------------------------------------------------------\\
     
                        ///////////////////////////////////////////////////////////////////////////////////////
                        //////////////////////////////// GESTURES AND COLLISION ///////////////////////////////
                        ///////////////////////////////////////////////////////////////////////////////////////
     
     \\-----------------------------------------------------------------------------------------------------------------------------*/

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
            
            if position.y + translation.y > 600 && position.y + translation.y < 750  && position.x + translation.x < 985 && position.x + translation.x > 41 {
                
                selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                
            }
                
            else {
                
                if position.x + translation.x < 1000 && position.x + translation.x > 15 {
                    
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
        
    }
    
     /*-----------------------------------------------------------------------------------------------------------------------------\\
     
                        ///////////////////////////////////////////////////////////////////////////////////////
                        ///////////////////////////////////// MISCELLANEOUS ///////////////////////////////////
                        ///////////////////////////////////////////////////////////////////////////////////////
     
     \\-----------------------------------------------------------------------------------------------------------------------------*/
    
    func precipSounds(rainCount: Double, hailCount: Double) {
        
        //If it's raining but the rain sound isn't playing
        if rainCount > 0 && playRainSound == false {
            
            playRainSound = true
            playSound("rainSound")
            if playHailSound == false { UIScreen.main.brightness = CGFloat(0.8) }
            
        } else if rainCount == 0 && playRainSound == true { //If it's not raining but the sound is still playing
            
            playRainSound = false
            rainPlayer.stop()
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
        
        cloudsPrecipitate()
        precipFalls()
        
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        loadSprites()   //load the background and sun when the scene initializes
        //let updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ourUpdate), userInfo: nil, repeats: true)
        //let updateTimer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(precipGoesDown), userInfo: nil, repeats: true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
}
