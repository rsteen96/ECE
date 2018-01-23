//
//  CreditScene.swift
//  ECE
//
//  Created by Will McAllister on 1/22/18.
//  Copyright © 2018 Will McAllister. All rights reserved.
//

import Foundation
import SpriteKit

class CreditScene: SKScene{

    var background = SKSpriteNode(imageNamed: "paperBackground")
    var credits = SKSpriteNode(imageNamed: "creditsTransparent")
    
    override func didMove(to view: SKView) {
        
        self.background.anchorPoint = CGPoint(x: 0, y: 0)
        self.background.position = CGPoint(x: 0, y: 0)
        self.background.zPosition = 0
        addChild(background)
        
        credits.position = CGPoint(x:frame.midX,y:frame.midY)
        credits.zPosition = 1
        self.addChild(credits)
    }
    
}





