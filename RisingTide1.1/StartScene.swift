//
//  StartScene.swift
//  Leapr
//
//  Created by Tim Baldyga on 7/15/15.
//  Copyright (c) 2015 Tim Baldyga. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation
import Social
import UIKit


class StartScene: SKScene, EGCDelegate {

    
    //Scale for Large iPhones
    var scaleFactor: CGFloat!
    
    var mute = UserDefaults().bool(forKey: "muteToggle")
    
    var backgroundMusicPlayer: AVAudioPlayer!
    var button = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
    
    //Button Nodes
    let lblPlay = SKSpriteNode(imageNamed: "play")
    let lblShare = SKSpriteNode(imageNamed: "share")
    let lblSettings = SKSpriteNode(imageNamed: "settings")
    let lblSound = SKSpriteNode(imageNamed: "sound")
    let lblMute = SKSpriteNode(imageNamed: "mute")
    let muteRound = SKShapeNode(circleOfRadius: 60)
    
    //Backround Nodes
    let logo = SKSpriteNode(imageNamed: "logoRisingtide")
    let player = SKSpriteNode(imageNamed: GameState.sharedInstance.player)
    let ground = SKSpriteNode(imageNamed: "ground")
    let cloud = SKSpriteNode(imageNamed: "cloud")
    let cloud2 = SKSpriteNode(imageNamed: "cloud")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //Backround Music
        //playBackgroundMusic("Water.wav")
        
        //Game Center
        EGC.showGameCenterAuthentication()
        func EGCAuthentified(_ authentified:Bool) {
            print("Player Authentified = \(authentified)")
        }
        
        scaleFactor = self.size.width / 320.0
        
        //Backround
        let background = SKSpriteNode(imageNamed: "background")
        background.setScale(scaleFactor)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(background)
        
        // Play
        lblPlay.setScale(scaleFactor)
        lblPlay.position = CGPoint(x: (self.size.width / 2), y: (self.size.height/2))
        addChild(lblPlay)
        
        //Share
        lblShare.setScale(scaleFactor)
        lblShare.position = CGPoint(x: (lblPlay.position.x - (lblPlay.size.width/2))/2, y: lblPlay.position.y)
        addChild(lblShare)
        
        //Settings
        lblSettings.setScale(scaleFactor)
        lblSettings.position = CGPoint(x: (lblPlay.position.x + (lblPlay.size.width/2)) + lblShare.position.x, y: lblShare.position.y)
        addChild(lblSettings)
        
        //Player
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.25)
        player.setScale(scaleFactor)
        addChild(player)
        
        //Ground
        ground.setScale(scaleFactor)
        ground.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        ground.position = CGPoint(x: self.size.width / 2, y: self.player.position.y - (player.size.height / 2 ))
        addChild(ground)
        
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
        
        //Vortex
        let sprite = SKSpriteNode(imageNamed: "water1")
        let sprite2 = SKSpriteNode(imageNamed: "water2")
        let sprite3 = SKSpriteNode(imageNamed: "water3")
        var moveVortex:SKAction!
        var repeatVortex:SKAction!
        
        sprite.setScale(scaleFactor)
        sprite2.setScale(scaleFactor)
        sprite3.setScale(scaleFactor)
        
        sprite.position = CGPoint(x: self.size.width / 2, y: (
            (ground.position.y - (sprite.size.height/2)) - (25))
        )
        
        sprite2.position = CGPoint(x: sprite.position.x, y: sprite.position.y - 10)
        sprite3.position = CGPoint(x: sprite.position.x, y: sprite.position.y - 20)
        
        sprite2.speed = 0.5
        sprite3.speed = 0.8
        
        addChild(sprite)
        addChild(sprite2)
        addChild(sprite3)
        
        let spriteArray = [sprite,sprite2,sprite3]
        for index in spriteArray{
            let upVortex = SKAction.moveTo(y: index.position.y + 5, duration:TimeInterval(1))
            let downVortex = SKAction.moveTo(y: index.position.y - 5, duration:TimeInterval(1))
            
            moveVortex = SKAction.sequence([upVortex, downVortex])
            repeatVortex = SKAction.repeatForever(moveVortex)
            
            index.run(repeatVortex)
        }
        
        //Cloud
        let cloudArray = [cloud,cloud2]
        
        cloud.name = "cloud"
        cloud2.name = "cloud2"
        cloud.position = CGPoint(x: self.frame.minX, y: self.size.height-60)
        cloud2.position = CGPoint(x: self.frame.maxX, y: cloud.position.y-cloud.size.height)

        var slidePlatforms:SKAction!
        var repeatPlatforms:SKAction!
        
        func randomBetweenNumbers(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
            return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
        }
        let diceRoll = randomBetweenNumbers(0.4, secondNum: 0.6)
        let size = CGFloat(diceRoll)
        cloud.speed = CGFloat(diceRoll * 100)
        cloud2.speed = CGFloat(diceRoll * 150)
        
        cloud.setScale(scaleFactor * diceRoll)
        cloud2.setScale(scaleFactor * (diceRoll + 0.2))
        addChild(cloud)
        addChild(cloud2)
        
        for index in cloudArray {
            
            let leftPlatform = SKAction.moveTo(x: self.frame.minX + (index.size.width / 2), duration:TimeInterval(index.speed*10))
            let rightPlatform = SKAction.moveTo(x: self.frame.maxX - (index.size.width / 2), duration:TimeInterval(index.speed*15))
            if index.name == "cloud" {slidePlatforms = SKAction.sequence([rightPlatform, leftPlatform])}
            else { slidePlatforms = SKAction.sequence([leftPlatform, rightPlatform]) }
            repeatPlatforms = SKAction.repeatForever(slidePlatforms)
            
            index.run(repeatPlatforms)
        }
        
        //Logo
        logo.setScale(scaleFactor)
        logo.position = CGPoint(x: self.size.width / 2, y: (
            (lblPlay.position.y + lblPlay.size.height/2) + ((self.size.height - (lblPlay.position.y + lblPlay.size.height/2))/2)
        ))
        addChild(logo)
        
    }
    
//    func playBackgroundMusic(filename: String) {
//        let url = NSBundle.mainBundle().URLForResource(
//            filename, withExtension: nil)
//        if (url == nil) {
//            print("Could not find file: \(filename)")
//            return
//        }
//        
//        var error: NSError? = nil
//        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: NSBundle.mainBundle().pathForResource("water", ofType: "wav")!), fileTypeHint:nil)
//        if backgroundMusicPlayer == nil {
//            print("Could not create audio player: \(error!)")
//            return
//        }
//        
//        backgroundMusicPlayer.numberOfLoops = -1
//        backgroundMusicPlayer.prepareToPlay()
//        backgroundMusicPlayer.play()
//    }
    
    override func didMove(to view: SKView) {
        
        //Swipe Actions
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(StartScene.handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(StartScene.handleSwipes(_:)))
        
        upSwipe.direction = .up
        downSwipe.direction = .down
        
        let wait = SKAction.wait(forDuration: 0.2)
        let run = SKAction.run { () -> Void in
            view.addGestureRecognizer(upSwipe)
            view.addGestureRecognizer(downSwipe)
            view.isUserInteractionEnabled = true
        }
        self.run(SKAction.sequence([wait,run]))
    
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //Play
            if atPoint(location) == self.lblPlay {
                // Transition back to the Game
                lblPlay.setScale(scaleFactor * 1.1)
            }
            else { lblPlay.setScale(scaleFactor) }
            
            //Settings
            if atPoint(location) == self.lblSettings {
                // Transition back to the Game
                lblSettings.setScale(scaleFactor * 1.1)
            }
            else { lblSettings.setScale(scaleFactor) }
            
            //Share
            if atPoint(location) == self.lblShare {
                // Transition back to the Game
                lblShare.setScale(scaleFactor * 1.1)
            }
            else { lblShare.setScale(scaleFactor) }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        

        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //play
            if atPoint(location) == self.lblPlay {
                // Transition back to the Game
                lblPlay.setScale(scaleFactor * 1.1)
            }
            
            //Settings
            if atPoint(location) == self.lblSettings {
                // Transition back to the Game
                lblSettings.setScale(scaleFactor * 1.1)
            }
            
            //Share
            if atPoint(location) == self.lblShare {
                // Transition back to the Game
                lblShare.setScale(scaleFactor * 1.1)
            }
        }
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let reveal = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: self.size)
        gameScene.name = "game"
        gameScene.mute = mute
        
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
                    let ping = SKAction.playSoundFileNamed("Click.wav", waitForCompletion: true)
                    if mute != true {run(ping)}
                    return
                }
            }
            
            //Play
            if atPoint(location) == self.lblPlay {
                //let ping = SKAction.playSoundFileNamed("Play.wav", waitForCompletion: true)
                if mute != true {playSound(sound: button)}
                
                // Transition back to the Game
                lblPlay.setScale(scaleFactor)
                self.view!.presentScene(gameScene, transition: reveal)
            }
            
            //Options Button
            if atPoint(location) == self.lblSettings {
                //let ping = SKAction.playSoundFileNamed("Play.wav", waitForCompletion: true)
                if mute != true {playSound(sound: button)}
                lblSettings.setScale(scaleFactor)
                
                let reveal = SKTransition.push(with: SKTransitionDirection.up, duration: 1.1)
                let optionScene = OptionScene(size: self.size)
                self.view!.presentScene(optionScene, transition: reveal)
                
            }
            
            //Share Button
            if atPoint(location) == self.lblShare {
                //let ping = SKAction.playSoundFileNamed("Play.wav", waitForCompletion: true)
                playSound(sound: button)
                lblShare.setScale(scaleFactor)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "shareButton"), object: nil)

            }
        }
    }
    
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .up) {
            //Screen goes down
            view!.isUserInteractionEnabled = false

            let reveal = SKTransition.push(with: SKTransitionDirection.up, duration: 1.1)
            let optionScene = OptionScene(size: self.size)
            view?.presentScene(optionScene, transition: reveal)
        }
        
        if (sender.direction == .down) {
            //Screen goes up
        }
    }
    
    func playSound(sound : SKAction)
    {
        run(sound)
    }
}
