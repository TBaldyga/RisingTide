//
//  OptionScene.swift
//  Rising Tide
//
//  Created by Tim Baldyga on 1/4/16.
//  Copyright © 2016 Tim Baldyga. All rights reserved.
//

import Foundation
import SpriteKit
import Social

class OptionScene: SKScene, EGCDelegate {
    
    //Zones for player select
    enum Zone {
        case left, center, right
    }
    
    //Scale for Large iPhones
    var scaleFactor: CGFloat!
    
    var players = [SKSpriteNode]()
    
    let lblHome = SKSpriteNode(imageNamed: "home")
    
    //Mute Variables
    var mute = UserDefaults().bool(forKey: "muteToggle")
    let lblSound = SKSpriteNode(imageNamed: "sound")
    let lblMute = SKSpriteNode(imageNamed: "mute")
    let muteRound = SKShapeNode(circleOfRadius: 60)
    
    //Initalization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        scaleFactor = self.size.width / 320.0
        
        backgroundColor = SKColor(red: 33.0/255.0, green: 150.0/255.0, blue: 166.0/255.0, alpha: 1.0)

        //Mute
        lblSound.position = CGPoint(x: self.size.width-25, y: self.size.height-25)
        lblSound.setScale(scaleFactor)
        addChild(lblSound)
        if mute == true {lblSound.isHidden = true}
        
        lblMute.position = CGPoint(x: self.size.width-25, y: self.size.height-25)
        lblMute.setScale(scaleFactor)
        addChild(lblMute)
        if mute == true {lblMute.isHidden = false}
        else {lblMute.isHidden = true}
        
        muteRound.position = CGPoint(x: self.size.width, y: self.size.height)
        muteRound.zPosition = 100
        muteRound.strokeColor = UIColor.clear
        addChild(muteRound)
        
        //Bubbles
        let sparkEmmiter = SKEmitterNode(fileNamed: "bubbles.sks")
        sparkEmmiter!.position = CGPoint(x: self.size.width/2, y: 0)
        sparkEmmiter!.particleLifetime = 10
        sparkEmmiter!.zPosition = -1
        addChild(sparkEmmiter!)
        
    }
    
    //This function can be used to create the array
    func createPlayers() {
        let nameArray = ["classic", "blue", "purple", "orange", "pink", "yellow", "green", "white"]
        
        for i in nameArray {
            let player = SKSpriteNode(imageNamed: "\(i)_ball")
            player.name = "\(i)_ball"
            players.append(player)
        }
    }
    
    override func didMove(to view: SKView) {
        
        //Swipe Actions
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OptionScene.handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(OptionScene.handleSwipes(_:)))
        upSwipe.direction = .up
        downSwipe.direction = .down
        //wait for load
        let wait = SKAction.wait(forDuration: 0.2)
        let run = SKAction.run { () -> Void in
            view.addGestureRecognizer(upSwipe)
            view.addGestureRecognizer(downSwipe)
            view.isUserInteractionEnabled = true
        }
        self.run(SKAction.sequence([wait,run]))
    }

    // Touch interactions
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
              //Home
            if atPoint(location) == self.lblHome {
                // Transition back to the Game
                lblHome.setScale(scaleFactor * 1.1)
            }
            else { lblHome.setScale(scaleFactor) }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //Home
            if atPoint(location) == self.lblHome {
                // Transition back to the Game
                lblHome.setScale(scaleFactor * 1.1)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //mute
            if atPoint(location) == self.muteRound {
                if mute == false {
                    lblSound.isHidden = true
                    lblMute.isHidden = false
                    mute = true
                    UserDefaults().set(true, forKey: "muteToggle")
                    return
                }
                if mute == true {
                    lblSound.isHidden = false
                    lblMute.isHidden = true
                    mute = false
                    UserDefaults().set(false, forKey: "muteToggle")
                    let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
                    if mute != true {run(ping)}
                    return
                }
            }

            //Home
            if atPoint(location) == self.lblHome {
                //let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
                if mute != true {run(ping)}
                lblHome.setScale(scaleFactor)
                
                // Transition back to start oage
                //let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Down, duration: 1.1)
                //let gameScene = StartScene(size: self.size)
                //gameScene.mute = mute
                //self.view!.presentScene(gameScene, transition: reveal)
                
                
                //Ball Toggle
                if GameState.sharedInstance.player == "classic_ball" {
                   GameState.sharedInstance.themeChange("neon_")
                }
                else {
                    GameState.sharedInstance.themeChange("classic_")

                }
            }
        }
    }
    
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .up) {
            //Screen goes down
        }
        
        if (sender.direction == .down) {
            //Screen goes up
            view!.isUserInteractionEnabled = false
            // Transition back to start page
            let reveal = SKTransition.push(with: SKTransitionDirection.down, duration: 1.1)
            let gameScene = StartScene(size: self.size)
            //gameScene.mute = mute
            self.view!.presentScene(gameScene, transition: reveal)
        }
    }
}
