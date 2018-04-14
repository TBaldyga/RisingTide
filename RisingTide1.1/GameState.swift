//
//  GameState.swift
//  Leapr
//
//  Created by Tim Baldyga on 7/3/15.
//  Copyright (c) 2015 Tim Baldyga. All rights reserved.
//

import Foundation
import GameKit

class GameState {
    
    //Basics
    var score: Int
    var highScore: Int
    var stars: Int
    var timesPlayed: Int
    
    //Toggle
    var mute: Bool
    
    //Customizations
    var player: String
    
    class var sharedInstance :GameState {
        struct Singleton {
            static let instance = GameState()
        }
        
        return Singleton.instance
    }
    
    init() {
        // Init
        score = 0
        highScore = 0
        stars = 0
        timesPlayed = 0
        
        mute = false
        
        // Load game state
        let defaults = UserDefaults.standard
        
        //Customization Defaults
        if defaults.string(forKey: "player") == nil {player = "classic_ball"}
        else {player = defaults.string(forKey: "player")!}
        
        //player = (defaults.stringForKey("player"))!
        highScore = defaults.integer(forKey: "highScore")
        stars = defaults.integer(forKey: "stars")
        timesPlayed = defaults.integer(forKey: "timesPlayed")
        //mute = defaults.boolForKey("muteToggle")
    }
    
    func themeChange(_ type: String) {
        
        let theme = type
        print(theme)
        
        let defaults = UserDefaults.standard
        defaults.set(theme, forKey: "player")
        
        //Save Theme
        let save = defaults.string(forKey: "player")
        player = save!
    }
    
    func saveState() {
        print("Save State")

        // Update highScore if the current score is greater
        highScore = max(score, highScore)
        timesPlayed = timesPlayed + 1
        
        // Store in user defaults
        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
        defaults.set(stars, forKey: "stars")
        UserDefaults.standard.synchronize()
  
        EGC.reportScoreLeaderboard(leaderboardIdentifier: "rt.leaderboard", score: highScore)
        print("\n[LeaderboardsActions] Score send to Game Center \(EGC.isPlayerIdentified)")
        
        //Update leaderboard
//        var leaderboardID = "rt.leaderboard"
//        var sScore = GKScore(leaderboardIdentifier: leaderboardID)
//        sScore.value = Int64(highScore)
//
//        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
//
//        GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError!) -> Void in
//            if error != nil {
//                print(error.localizedDescription)
//            } else {
//                print("Score submitted")
//                
//            }
//        })
        
        if timesPlayed == 100 {
            //EasyGameCenter.reportAchievement(progress: 100.00, achievementIdentifier: "score_50points", addToExisting: true)
        }
        
        //Parse Analytics
        let dimensions = [
            "score" : String(format: "%d", score),    // users session score
            "highScore" : String(format: "%d", highScore), //users current high schore
            "timesPlayed" : String(format: "%d", timesPlayed), // number of times the user has played the game
            "deviceID" : UIDevice.current.identifierForVendor!.uuidString // Device ID
        ]
        
        // Send the dimensions to Parse along with the 'read' event
        PFAnalytics.trackEvent("gameData", dimensions: dimensions)
        print("Data Sent")
        
        //Changes ball Color
        let ballArray = ["classic", "blue", "purple", "orange", "pink", "yellow", "green", "white"]
        let ballState = GameState.sharedInstance.player
        print(ballState)
        
        repeat{
            let diceRoll = Int(arc4random_uniform(UInt32(8)))
            GameState.sharedInstance.player = "\(ballArray[diceRoll])_ball"
        } while GameState.sharedInstance.player == ballState
        
            //for diceRoll in nameArray {
                //let ball = SKSpriteNode(imageNamed: "\(i)_ball")
                //ball.name = "\(i)_ball"
                //players.append(player)
            //}


    }
    
}
