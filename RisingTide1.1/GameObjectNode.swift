//
//  GameObjectNode.swift
//  Leapr
//
//  Created by Tim Baldyga on 7/1/15.
//  Copyright (c) 2015 Tim Baldyga. All rights reserved.
//

import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
    static let Vortex: UInt32 = 0x03
    
}

enum PlatformType: Int {
    case normal = 0
    case `break`
}

class GameObjectNode: SKNode {
    func collisionWithPlayer(_ player: SKNode) -> Bool {
        return false
    }
    
    func checkNodeRemoval(_ playerY: CGFloat) {
        if playerY > self.position.y + 200.0 {
            self.physicsBody?.isDynamic = true
        }
    }
}

class VortexNode: GameObjectNode {

        //Blow the player up?
        //Play sound
        //println("GAME OBJECT NODE")

        //The HUD does not need to be updated
        //return false
   
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType!
    let ping = SKAction.playSoundFileNamed("Coin.wav", waitForCompletion: false)
    var mute = UserDefaults().bool(forKey: "muteToggle")

    
     override func collisionWithPlayer(_ player: SKNode) -> Bool {
        // Only interact with the player if he's falling
        if player.physicsBody?.velocity.dy < 0 {
            player.physicsBody!.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 0)
            player.physicsBody!.affectedByGravity = false
            
            //1.1 Update to Stop the platform
            removeAllActions()

            if mute != true {run(ping)}
            GameState.sharedInstance.score += (1)
        
            // Remove if it is a Break type platform
            if platformType == .break {
                self.removeFromParent()
            }
        }

        return false
    }
}

class StarNode: GameObjectNode {
    
    let ping = SKAction.playSoundFileNamed("OLD_Ping.wav", waitForCompletion: false)
    
    override func collisionWithPlayer(_ player: SKNode) -> Bool {
        // Boost the player up
        // Remove this Star
        // Play sound
        run(ping, completion: {
            // Remove this Star
            self.removeFromParent()
        })
        
        GameState.sharedInstance.stars += 1
        // The HUD needs updating to show the new stars and score
        return true
    }
}
