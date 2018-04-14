//
//  EndGame.swift
//  Leapr
//
//  Created by Tim Baldyga on 7/3/15.
//  Copyright (c) 2015 Tim Baldyga. All rights reserved.
//

import SpriteKit
import Social

class EndGameScene: SKScene, EGCDelegate {
        
    //Scale for Large iPhones
    var scaleFactor: CGFloat!
    
    let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
    
    var mute = UserDefaults().bool(forKey: "muteToggle")
    
    let scoreBoard = SKSpriteNode(imageNamed: "scoreboard")
    let lblTryAgain = SKSpriteNode(imageNamed: "replay")
    let lblLeaderBoard = SKSpriteNode(imageNamed: "leaderboard")
    let lblRate = SKSpriteNode(imageNamed: "rateicon")
    let lblHome = SKSpriteNode(imageNamed: "home")
    let lblFacebook = SKSpriteNode(imageNamed: "facebook")
    let lblTwitter = SKSpriteNode(imageNamed: "twitter")
    let gameOver = SKSpriteNode(imageNamed: "logoGameover")

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        scaleFactor = self.size.width / 320.0
        
        backgroundColor = SKColor(red: 33.0/255.0, green: 150.0/255.0, blue: 166.0/255.0, alpha: 1.0)
        
        //Backround
        let background = SKSpriteNode(imageNamed: "endBackground")
        background.setScale(scaleFactor)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        //addChild(background)
        
        //scoreboard
        scoreBoard.setScale(scaleFactor)
        scoreBoard.position = CGPoint(x: self.size.width / 2, y: (self.size.height + 100) / 2)
        addChild(scoreBoard)
        
        //Game Over
        gameOver.setScale(scaleFactor)
        gameOver.position = CGPoint(x: self.size.width / 2, y: (
            (scoreBoard.position.y + scoreBoard.size.height/2) + ((self.size.height - (scoreBoard.position.y + scoreBoard.size.height/2))/2)
        ))
        addChild(gameOver)
        
        // Try again
        lblTryAgain.setScale(scaleFactor)
        lblTryAgain.position = CGPoint(x: (self.size.width / 2) + (lblHome.size.width/2 + lblLeaderBoard.size.width/2),
                                    y: ((scoreBoard.position.y - (scoreBoard.size.height/2)) + 50)/1.66)
        addChild(lblTryAgain)
        
        //Leaderboard
        lblLeaderBoard.setScale(scaleFactor)
        lblLeaderBoard.position = CGPoint(x: (self.size.width / 2) - (lblHome.size.width/2 + lblLeaderBoard.size.width/2),
                                            y: lblTryAgain.position.y)
        addChild(lblLeaderBoard)
        
        //Rate
        lblHome.setScale(scaleFactor)
        lblHome.position = CGPoint(x: self.size.width / 2,
            y: ((lblLeaderBoard.position.y - (lblLeaderBoard.size.height/2)) + 50)/2 )
        addChild(lblHome)
        
        //Twitter
        lblTwitter.setScale(scaleFactor)
        lblTwitter.position = CGPoint(x: lblHome.position.x + lblHome.size.width * 2, y: lblHome.position.y)
        addChild(lblTwitter)
        
        //Facebook
        lblFacebook.setScale(scaleFactor)
        lblFacebook.position = CGPoint(x: lblHome.position.x - lblHome.size.width * 2, y: lblHome.position.y)
        addChild(lblFacebook)
        
        //Home
        //lblHome.position = CGPoint(x: 25, y: self.size.height-25)
        //lblHome.setScale(scaleFactor)
        //addChild(lblHome)
        
        // Stars
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: self.size.height-30)
        //addChild(star)
        
        let lblStars = SKLabelNode(fontNamed: "Arial-BoldMT")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        //addChild(lblStars)
        
        // High Score White
        let lblHighScoreBack = SKLabelNode(fontNamed: "VacationPostcardBold")
        lblHighScoreBack.fontSize = 25
        lblHighScoreBack.setScale(scaleFactor)
        lblHighScoreBack.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblHighScoreBack.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        lblHighScoreBack.fontColor = SKColor.white
        lblHighScoreBack.position = CGPoint(x: self.size.width / 2, y: scoreBoard.position.y + (scoreBoard.size.height/4))
        lblHighScoreBack.text = String(format: "High Score %d", GameState.sharedInstance.highScore)
        addChild(lblHighScoreBack)
        
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "VacationPostcardNF")
        lblHighScore.fontSize = 25
        lblHighScore.setScale(scaleFactor)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblHighScore.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        lblHighScore.fontColor = SKColor.black
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: scoreBoard.position.y + (scoreBoard.size.height/4))
        lblHighScore.text = String(format: "High Score %d", GameState.sharedInstance.highScore)
        addChild(lblHighScore)
        
        // Score White
        let lblScoreBack = SKLabelNode(fontNamed: "VacationPostcardBold")
        lblScoreBack.fontSize = 50
        lblScoreBack.setScale(scaleFactor)
        lblScoreBack.fontColor = SKColor.white
        lblScoreBack.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblScoreBack.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        lblScoreBack.position = CGPoint(x: self.size.width / 2, y: ((lblHighScore.position.y + (scoreBoard.position.y-scoreBoard.size.height/2))/2)-5)
        lblScoreBack.text = String(format: "%d", GameState.sharedInstance.score)
        addChild(lblScoreBack)
        
        // Score
        let lblScore = SKLabelNode(fontNamed: "VacationPostcardNF")
        lblScore.fontSize = 50
        lblScore.setScale(scaleFactor)
        lblScore.fontColor = SKColor.black
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblScore.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        lblScore.position = CGPoint(x: self.size.width / 2, y: ((lblHighScore.position.y + (scoreBoard.position.y-scoreBoard.size.height/2))/2)-5)
        lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        addChild(lblScore)
        
        let sparkEmmiter = SKEmitterNode(fileNamed: "bubbles.sks")
        sparkEmmiter!.position = CGPoint(x: self.size.width/2, y: 0)
        sparkEmmiter!.particleLifetime = 10
        sparkEmmiter!.zPosition = -1
        addChild(sparkEmmiter!)
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //Replay
            if atPoint(location) == self.lblTryAgain {
                // Transition back to the Game
                lblTryAgain.setScale(scaleFactor * 1.1)
            }
            else { lblTryAgain.setScale(scaleFactor) }
            
            //Home
            if atPoint(location) == self.lblHome {
                // Transition back to the Game
                lblHome.setScale(scaleFactor * 1.1)
            }
            else { lblHome.setScale(scaleFactor) }
            
            //Leederboard
            if atPoint(location) == self.lblLeaderBoard {
                // Transition back to the Game
                lblLeaderBoard.setScale(scaleFactor * 1.1)
            }
            else { lblLeaderBoard.setScale(scaleFactor) }
            
            //Twitter
            if atPoint(location) == self.lblTwitter {
                // Transition back to the Game
                lblTwitter.setScale(scaleFactor * 1.1)
            }
            else { lblTwitter.setScale(scaleFactor) }
            
            //Facebook
            if atPoint(location) == self.lblFacebook {
                // Transition back to the Game
                lblFacebook.setScale(scaleFactor * 1.1)
            }
            else { lblFacebook.setScale(scaleFactor) }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            
            //Replay
            if atPoint(location) == self.lblTryAgain {
                // Transition back to the Game
                lblTryAgain.setScale(scaleFactor * 1.1)
            }
            
            //Rate
            if atPoint(location) == self.lblHome {
                // Transition back to the Game
                lblHome.setScale(scaleFactor * 1.1)
            }
            
            //Leederboard
            if atPoint(location) == self.lblLeaderBoard {
                // Transition back to the Game
                lblLeaderBoard.setScale(scaleFactor * 1.1)
            }
            
            //Twitter
            if atPoint(location) == self.lblTwitter {
                // Transition back to the Game
                lblTwitter.setScale(scaleFactor * 1.1)
            }
            
            //Facebook
            if atPoint(location) == self.lblFacebook {
                // Transition back to the Game
                lblFacebook.setScale(scaleFactor * 1.1)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //Replay
            if atPoint(location) == self.lblTryAgain {
                //let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
                if mute != true {run(ping)}

                // Transition back to the Game
                lblTryAgain.setScale(scaleFactor)
                let reveal = SKTransition.fade(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                gameScene.name = "game"
                //gameScene.mute = mute
                self.view!.presentScene(gameScene, transition: reveal)
            }
            
            //Rate
            if atPoint(location) == self.lblHome {
                //let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
                if mute != true {run(ping)}
                lblHome.setScale(scaleFactor)

                // Transition back to start oage
                let reveal = SKTransition.fade(withDuration: 0.5)
                let gameScene = StartScene(size: self.size)
                //gameScene.mute = mute
                self.view!.presentScene(gameScene, transition: reveal)
            }
            
            //Leaderboard
            if atPoint(location) == self.lblLeaderBoard {
                //let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
                if mute != true {run(ping)}
                lblLeaderBoard.setScale(scaleFactor)
                EGC.showGameCenterLeaderboard(leaderboardIdentifier: "rt.leaderboard")

            }
            
            //Twitter
            if atPoint(location) == self.lblTwitter {
                //let ping = SKAction.playSoundFileNamed("Play.wav", waitForCompletion: true)
                if mute != true {run(ping)}
                lblTwitter.setScale(scaleFactor)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.twitter"), object: nil)
                //EasyGameCenter.showCustomBanner(title: "Title", description: "My Description...")
            }
            
            //Facebook
            if atPoint(location) == self.lblFacebook {
                //let ping = SKAction.playSoundFileNamed("Play.wav", waitForCompletion: true)
                if mute != true {run(ping)}
                lblFacebook.setScale(scaleFactor)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "com.facebook"), object: nil)
            }
        }
    }
}
