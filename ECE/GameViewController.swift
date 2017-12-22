//
//  GameViewController.swift
//  ECE-iOS application
//
//  Created by Arlo Miles Cohen on 10/26/17.
//  Copyright © 2017 Arlo Miles Cohen. All rights reserved.
//

import UIKit
import SpriteKit
import CoreData

class GameViewController: UIViewController {

    override func viewWillLayoutSubviews() {
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        let scene = MenuScene(size: skView.frame.size)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
    }
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Storing core data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newGame = NSEntityDescription.insertNewObject(forEntityName: "GameObjects", into: context)
 
        let cloud = "cloud.png"
        let balloon = "looner.png"
        let horse = "horse-normal.png"
        let sun = "sun.png"
        
        let cloudImg = UIImage(named: cloud)
        let balloonImg = UIImage(named: balloon)
        let horseImg = UIImage(named: horse)
        let sunImg = UIImage(named: sun)
        
        let cloudData = UIImagePNGRepresentation(cloudImg!) as NSData?
        let balloonData = UIImagePNGRepresentation(balloonImg!) as NSData?
        let horseData = UIImagePNGRepresentation(horseImg!) as NSData?
        let sunData = UIImagePNGRepresentation(sunImg!) as NSData?
        
        newGame.setValue(cloudData, forKey: "cloud")
        newGame.setValue(balloonData, forKey: "balloon")
        newGame.setValue(horseData, forKey: "horse")
        newGame.setValue(sunData, forKey: "sun")

        do{
            try context.save()
            print("saved")
        } catch{
            //PROCESS ERROR
        }
        
        //let request = NSFetchRequest<NSFetchRequestResult>(entityNamed: "GameObjects")
        //request.returnObjectsAsFaults = false
        
    }
    */
    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
