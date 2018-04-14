//
//  GameScene.swift
//  risingtide
//
//  Created by Tim Baldyga on 7/21/15.
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


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let ping = SKAction.playSoundFileNamed("Jump.wav", waitForCompletion: false)
    
    // Layered Nodes
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    var pauseNode: SKNode!
    var player: SKNode!
    var vortex: SKNode!
    var ground: SKNode!
    
    var mute = UserDefaults().bool(forKey: "muteToggle")
    
    //Text nodes
    var lblScore: SKLabelNode!
    var lblScoreBack: SKLabelNode!
    var lblStars: SKLabelNode!
    var lblStart: SKSpriteNode!
    var hudPause: SKSpriteNode!
    var hudUnpause: SKSpriteNode!
    var pauseRound: SKShapeNode!
    var logoPaused: SKSpriteNode!
    var pauseFilter: SKSpriteNode!

    var cloudEmmiter: SKEmitterNode!
    
    // Tap To Start node
    let tapToStartNode = SKSpriteNode(imageNamed: "play")
    
    //Scale for Large iPhones
    var scaleFactor: CGFloat!
    
    var startOff: CGFloat!
    
    func pauseGame() {
        if isPaused == false {
            hudPause.isHidden = true
            pauseNode.isHidden = false
            isPaused = true
        }
        return
    }
    
    // Height at which level ends
    var endLevelY = 0
    
    // Max y reached by player
    var maxPlayerY: Int!
    
    // Game over
    var gameOver = false
    var deathBool = false //Stops touch
    
    enum ColliderType:UInt32 {
        case ball = 2
        case platform = 1
        case vortex = 3
    }
    
    //Initilization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor(red: 165.0/255.0, green: 227.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.0)
        physicsWorld.contactDelegate = self
        
        scaleFactor = self.size.width / 320.0
        
        //Backround
        let background = SKSpriteNode(imageNamed: "background")
        background.setScale(scaleFactor)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(background)
        
        // Create the game nodes
        // Background
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        
        // Reset
        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false
        
        // Foreground
        foregroundNode = SKNode()
        addChild(foregroundNode)
        
        
        // Build the HUD
        // HUD
        hudNode = SKNode()
        addChild(hudNode)
        
        // Pause
        pauseNode = SKNode()
        hudNode.addChild(pauseNode)
        pauseNode.zPosition = 99
        pauseNode.isHidden = true
        
        pauseFilter = SKSpriteNode(imageNamed: "pauseFilter")
        pauseFilter.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        pauseFilter.setScale(scaleFactor)
        pauseNode.addChild(pauseFilter)
        
        hudUnpause = SKSpriteNode(imageNamed: "play")
        hudUnpause.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        hudUnpause.setScale(scaleFactor)
        pauseNode.addChild(hudUnpause)
        
        logoPaused = SKSpriteNode(imageNamed: "logoPaused")
        logoPaused.position = CGPoint(x: self.size.width/2, y:
            (hudUnpause.position.y + hudUnpause.size.height/2) + ((self.size.height - (hudUnpause.position.y + hudUnpause.size.height/2))/2)
        )
        logoPaused.setScale(scaleFactor)
        pauseNode.addChild(logoPaused)
        
        hudPause = SKSpriteNode(imageNamed: "pause")
        hudPause.position = CGPoint(x: 25, y: self.size.height-25)
        hudPause.setScale(scaleFactor)
        hudNode.addChild(hudPause)

        pauseRound = SKShapeNode(circleOfRadius: 60)
        pauseRound.position = CGPoint(x: self.frame.minX, y: self.size.height)
        pauseRound.zPosition = 100
        pauseRound.strokeColor = UIColor.clear
        hudNode.addChild(pauseRound)
        
        // Coins
        let hudStar = SKSpriteNode(imageNamed: "Star")
        hudStar.position = CGPoint(x: 25, y: self.size.height-30)
        //hudNode.addChild(hudStar)
        
        lblStars = SKLabelNode(fontNamed: "Arial-BoldMT")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        lblStars.text = String(format: "= %d", GameState.sharedInstance.stars)
        //hudNode.addChild(lblStars)
        
        // Back Score
        lblScoreBack = SKLabelNode(fontNamed: "VacationPostcardBold")
        lblScoreBack.fontSize = 40 * scaleFactor
        lblScoreBack.fontColor = SKColor.white
        lblScoreBack.position = CGPoint(x: self.size.width/2, y: self.size.height-40)
        lblScoreBack.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        
        lblScoreBack.text = "0"
        hudNode.addChild(lblScoreBack)
        
        // Score
        lblScore = SKLabelNode(fontNamed: "VacationPostcardNF")
        lblScore.fontSize = 40 * scaleFactor
        lblScore.fontColor = SKColor.black
        lblScore.position = CGPoint(x: self.size.width/2, y: self.size.height-40)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        
        lblScore.text = "0"
        hudNode.addChild(lblScore)
        
        // Load the level
        //let levelPlist = NSBundle.mainBundle().pathForResource("Level01", ofType: "plist")
        //let levelData = NSDictionary(contentsOfFile: levelPlist!)!
        
        // Height at which the player ends the level
        endLevelY =  20500 //levelData["EndY"]!.integerValue!
        
        cloudEmmiter = SKEmitterNode(fileNamed: "clouds.sks")
        cloudEmmiter.position = CGPoint(x: -10, y: self.size.height/2)
        cloudEmmiter.particleLifetime = 40
        cloudEmmiter.zPosition = 1
        //backgroundNode.addChild(cloudEmmiter)

        // Add the player
        player = createPlayer()
        player.zPosition = 50
        foregroundNode.addChild(player)
        
        startOff = player.position.y + 180

        //Clouds
        for index in 0...20 {
            var x = self.frame.minX
            var y = ((500 * index) + 300)
            var randIndx = CGFloat(index)
            var positionX = CGFloat(x)
            var positionY = CGFloat(y)
            func randomBetweenNumbers(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
                return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
            }
            var diceRoll = randomBetweenNumbers(0.4, secondNum: 0.8)
            let size = CGFloat(diceRoll)
            let speed = CGFloat(diceRoll * 20)
            let point = CGPoint(x: positionX, y: positionY)
            //let cloudNode = createClouds((CGPoint(x: positionX, y: positionY), size: , speed: speed))
            let cloudNode = createCloud(point, size: size, speed: speed)
            backgroundNode.addChild(cloudNode)
            
            //greet(person: "Tim", alreadyGreeted: true)
            //createClouds(position: CGPoint, size: CGFloat, speed: CGFloat)
        }
        
        // Add the platforms
        for index in 0...100 {
            var x = self.frame.maxX
            var y = Int(startOff) + (index * 200)
            var randIndx = CGFloat(index)
            var type = PlatformType.normal
            var positionX = CGFloat(x)
            var positionY = CGFloat(y)
            var sLow = CGFloat(2.2 - (randIndx / 100))
            var sHigh = CGFloat(1.4 - (randIndx / 100))
            let platformNode = createPlatformAtPosition(CGPoint(x: positionX, y: positionY), ofType: type, speedLow: sLow, speedHigh: sHigh)
            foregroundNode.addChild(platformNode)

        }
        
        // Add the star
        //        let starArray = [800,1000,1200,1400]
        //        for index in 1...20 {
        //            let diceRoll = Int(arc4random_uniform(3))
        //            let x = CGRectGetMidX(self.frame)
        //            let y = (starArray[diceRoll] * index)
        //            let randIndx = CGFloat(index)
        //            let positionX = CGFloat(x)
        //            let positionY = CGFloat(y)
        //            let starNode = createStarAtPosition(CGPoint(x: positionX, y: positionY))
        //            foregroundNode.addChild(starNode)
        //        }
        
        //Ground
        ground = createGround()
        foregroundNode.addChild(ground)
        
        // Vortex
        vortex = createVortex()
        foregroundNode.addChild(vortex)
        
        // Tap to Start
        lblStart = SKSpriteNode(imageNamed: "tap")
        lblStart.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.35)
        hudNode.addChild(lblStart)
        
    }
    
    //Function for Backround(?)
    func createBackgroundNode() -> SKNode {
        // Create the node
        let backgroundNode = SKNode()
        let ySpacing = 64.0 * scaleFactor
        
        return backgroundNode
        
    }
    
    //Function for Clouds
    func createCloud(_ position: CGPoint, size: CGFloat, speed: CGFloat) -> PlatformNode {
        
        let sprite = SKSpriteNode(imageNamed: "cloud")
        var sprite2 = SKSpriteNode(imageNamed: "cloud")
        
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor - (sprite.size.width / 1.999), y: position.y + (self.size.height * 0.50))
        var slidePlatforms:SKAction!
        var repeatPlatforms:SKAction!
        
        
        
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        sprite.setScale(scaleFactor * size)
        
        node.addChild(sprite)
        
        
        let leftPlatform = SKAction.moveTo(x: self.frame.minX + (sprite.size.width / 2), duration:TimeInterval(speed))
        let rightPlatform = SKAction.moveTo(x: self.frame.maxX - (sprite.size.width / 2), duration:TimeInterval(speed))
        
        slidePlatforms = SKAction.sequence([leftPlatform, rightPlatform])
        repeatPlatforms = SKAction.repeatForever(slidePlatforms)
        
        
        node.run(repeatPlatforms)
        
        return node
    }
    
    func createClouds(position: CGPoint, size: CGFloat, speed: CGFloat) -> PlatformNode {
        
        let cloud1 = SKSpriteNode(imageNamed: "cloud")
        let cloud2 = SKSpriteNode(imageNamed: "cloud")
        let cloudArray = [cloud1,cloud2]
        
        let cloudNode = SKNode()
        let node = PlatformNode()
        
        cloud1.name = "cloud1"
        cloud2.name = "cloud2"
        cloud1.position = CGPoint(x: self.frame.minX, y: position.y)
        cloud2.position = CGPoint(x: self.frame.maxX, y: position.y + 150)
        
        cloud1.speed = CGFloat(speed * 200)
        cloud2.speed = CGFloat(speed * 300)
        
        cloud1.setScale(size)
        cloud2.setScale(size * 0.8)
        cloudNode.addChild(cloud1)
        cloudNode.addChild(cloud2)
        
        var slidePlatforms:SKAction!
        var repeatPlatforms:SKAction!
        
        for index in cloudArray {
            
            let leftPlatform = SKAction.moveTo(x: self.frame.minX + (index.size.width / 2), duration:TimeInterval(index.speed*10))
            let rightPlatform = SKAction.moveTo(x: self.frame.maxX - (index.size.width / 2), duration:TimeInterval(index.speed*15))
            if index.name == "cloud1" {slidePlatforms = SKAction.sequence([rightPlatform, leftPlatform])}
            else { slidePlatforms = SKAction.sequence([leftPlatform, rightPlatform]) }
            repeatPlatforms = SKAction.repeatForever(slidePlatforms)
            
            index.run(repeatPlatforms)
        }
        
        node.addChild(cloudNode)
        return node
    }
    
    //Function for Ground
    func createGround() -> SKNode {
        let groundNode = SKNode()
        
        let player = SKSpriteNode(imageNamed: GameState.sharedInstance.player)
        player.setScale(scaleFactor)
        
        let ground = SKSpriteNode(imageNamed: "ground")
        
        ground.setScale(scaleFactor)
        ground.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        groundNode.addChild(ground)
        groundNode.position = CGPoint(x: self.size.width / 2, y: self.player.position.y - (player.size.height / 2 ))
        
        return(groundNode)
    }
    
    
    //Function for Vortex
    func createVortex() -> VortexNode {
        let vortexNode = VortexNode()
        vortexNode.name = "NODE_VORTEX"
        
        var moveVortex:SKAction!
        var repeatVortex:SKAction!
        
        let sprite = SKSpriteNode(imageNamed: "water1")
        let sprite2 = SKSpriteNode(imageNamed: "water2")
        let sprite3 = SKSpriteNode(imageNamed: "water3")
        
        sprite.setScale(scaleFactor)
        sprite2.setScale(scaleFactor)
        sprite3.setScale(scaleFactor)
        
        vortexNode.position = CGPoint(x: self.size.width / 2, y: (
            (ground.position.y - (sprite.size.height/2)) - (25))
        )
        
        sprite2.position.y = sprite.position.y - 10
        sprite3.position.y = sprite.position.y - 20
        
        sprite2.speed = 0.5
        sprite3.speed = 0.8
        
        sprite3.zPosition = 60
        
        vortexNode.addChild(sprite)
        vortexNode.addChild(sprite2)
        vortexNode.addChild(sprite3)
        
        
        var newFrame = CGRect(x: 0, y: 0, width: sprite.size.width, height: sprite.size.height)
        vortexNode.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        vortexNode.physicsBody?.isDynamic = true
        vortexNode.physicsBody?.affectedByGravity = false
        vortexNode.physicsBody?.allowsRotation = false
        
        vortexNode.physicsBody?.usesPreciseCollisionDetection = true
        vortexNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Vortex
        vortexNode.physicsBody?.collisionBitMask = 0
        //vortexNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Player | CollisionCategoryBitmask.Platform
        
        
        let spriteArray = [sprite,sprite2,sprite3]
        for index in spriteArray{
            let upVortex = SKAction.moveTo(y: index.position.y + 5, duration:TimeInterval(1))
            let downVortex = SKAction.moveTo(y: index.position.y - 5, duration:TimeInterval(1))
            
            moveVortex = SKAction.sequence([upVortex, downVortex])
            repeatVortex = SKAction.repeatForever(moveVortex)
            
            
            index.run(repeatVortex)
            
        }
        
        
        return vortexNode
    }
    
    //Function for Player
    func createPlayer() -> SKNode {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.25)
        
        //Visible Sprite
        let sprite = SKSpriteNode(imageNamed: GameState.sharedInstance.player)
        //sprite.anchorPoint = CGPointMake(0.5, 0)
        sprite.setScale(scaleFactor)
        
        //Point Node for Physics
        let point = SKSpriteNode()
        
        playerNode.addChild(sprite)
        playerNode.addChild(point)
        
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.restitution = 0.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform | CollisionCategoryBitmask.Vortex
        
        return playerNode
    }
    
    //Function for Platforms
    func createPlatformAtPosition(_ position: CGPoint, ofType type: PlatformType, speedLow: CGFloat, speedHigh: CGFloat) -> PlatformNode {
        
        var sprite: SKSpriteNode
        if type == .break {
            sprite = SKSpriteNode(imageNamed: "platform")
        } else {
            sprite = SKSpriteNode(imageNamed: "platform")
        }
        
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor - (sprite.size.width / 1.999), y: position.y)
        var slidePlatforms:SKAction!
        var repeatPlatforms:SKAction!
        
        let sLow = speedLow
        let sHigh = speedHigh
        
        print(node.position)
        
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        sprite.setScale(scaleFactor)
        //sprite.anchorPoint = CGPointMake(0.5, 1)
        node.addChild(sprite)
        
        node.physicsBody?.usesPreciseCollisionDetection = true
        node.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        //node.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-(sprite.size.width/2), 0), toPoint: CGPointMake(sprite.size.width/2, 0))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0
        
        func randomBetweenNumbers(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
            return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
        }
        
        var diceRoll = randomBetweenNumbers(sLow, secondNum: sHigh)
        
        let leftPlatform = SKAction.moveTo(x: self.frame.minX + (sprite.size.width / 2), duration:TimeInterval(diceRoll))
        let rightPlatform = SKAction.moveTo(x: self.frame.maxX - (sprite.size.width / 2), duration:TimeInterval(diceRoll))
        
        slidePlatforms = SKAction.sequence([leftPlatform, rightPlatform])
        repeatPlatforms = SKAction.repeatForever(slidePlatforms)
        
        
        node.run(repeatPlatforms)
        
        return node
    }
    
    //Function for Star
    func createStarAtPosition(_ position: CGPoint) -> StarNode {
        let node = StarNode()
        let thePosition = CGPoint(x: self.size.width / 2, y: position.y)
        node.position = thePosition
        node.name = "NODE_STAR"
        
        var sprite: SKSpriteNode
        sprite = SKSpriteNode(imageNamed: "Star")
        node.addChild(sprite)
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    //Function to end Game
    func endGame() {
        gameOver = true
        let reveal = SKTransition.push(with: SKTransitionDirection.up, duration: 1.1)
        // Save score and high score
        //GameState.sharedInstance.saveState()
        
        let endGameScene = EndGameScene(size: self.size)
        //endGameScene.mute = mute

        let wait = SKAction.wait(forDuration: 0.5)
        let run = SKAction.run { () -> Void in
            self.view!.presentScene(endGameScene, transition: reveal)
        }
        self.run(SKAction.sequence([wait,run]))
    }
    
    //Function for Platform Generation
    func platformGen()
    {
            var index = 2
            var x = self.frame.maxX
            var y = Int(startOff) + (index * 200)
            var randIndx = CGFloat(index)
            var type = PlatformType.normal
            var positionX = CGFloat(x)
            var positionY = CGFloat(y)
            var sLow = CGFloat(2.2 - (randIndx / 100))
            var sHigh = CGFloat(1.4 - (randIndx / 100))
            let platformNode = createPlatformAtPosition(CGPoint(x: positionX, y: positionY), ofType: type, speedLow: sLow, speedHigh: sHigh)
            foregroundNode.addChild(platformNode)
            print(positionY)

    }
    
    //Function for Touch
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Touching Nodes
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //Pause
            if atPoint(location) == self.pauseRound {
                let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
                if mute != true {run(ping)}
                hudPause.setScale(scaleFactor)
                if isPaused == false {
                    hudPause.isHidden = true
                    pauseNode.isHidden = false
                    isPaused = true
                    return
                }
            }
            if atPoint(location) == self.hudUnpause {
                if isPaused == true {
                    isPaused = false
                    hudUnpause.setScale(scaleFactor)
                    let ping = SKAction.playSoundFileNamed("Button.wav", waitForCompletion: true)
                    if mute != true {run(ping)}
                    pauseNode.isHidden = true
                    hudPause.isHidden = false
                    return
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            if atPoint(location) == self.pauseRound {
                hudPause.setScale(scaleFactor * 1.3)
            }
            else { hudPause.setScale(scaleFactor) }
            
            if atPoint(location) == self.hudUnpause {
                hudUnpause.setScale(scaleFactor * 1.1)
            }
            else { hudUnpause.setScale(scaleFactor) }
        }
    }
    
    
    //Function for Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //Touching Nodes
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            //Pause
            if atPoint(location) == self.pauseRound {
                hudPause.setScale(scaleFactor * 1.3)
                return
            }
            if atPoint(location) == self.hudUnpause {
                if isPaused == true {
                hudUnpause.setScale(scaleFactor * 1.1)
                return
                }
            }
        }
        
        if isPaused == true {return}
        
        //Normal Tap
        if !deathBool {
            // If we're already playing:
            if player.physicsBody!.isDynamic && !player.physicsBody!.affectedByGravity {
                physicsWorld.removeAllJoints()
                player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 800)
                player.physicsBody?.affectedByGravity = true
                if mute != true {run(ping)}
            }
    
            //Start the Game:
            if !player.physicsBody!.isDynamic && player.physicsBody!.affectedByGravity {
                
                // Remove the Tap to Start node
                lblStart.removeFromParent()
                
                // Start the player by putting them into the physics simulation
                player.physicsBody?.isDynamic = true
                
                //Temp Start jump
                //player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 23))
                player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 800)
                if mute != true {run(ping)}
            }
        }
    }
    
    //Function for Contact/Collision
    func didBegin(_ contact: SKPhysicsContact) {
        var updateHUD = true
        maxPlayerY = Int(player.position.y)
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        
        //If the Player hits the Vortex
        if whichNode?.name == "NODE_VORTEX" {
            //Save Game
            GameState.sharedInstance.saveState()
            //Mark the game var as dead
            deathBool = true
            //Let the player fall
            player.physicsBody!.isDynamic = true
            player.physicsBody!.affectedByGravity = true
            //Play the sound and make the splash animation
            let deathSound = SKAction.playSoundFileNamed("Death.wav", waitForCompletion: false)
            let sparkEmmiter = SKEmitterNode(fileNamed: "Sparks.sks")
            sparkEmmiter!.position = CGPoint(x: player.position.x, y: contact.contactPoint.y)
            sparkEmmiter!.particleLifetime = 1
            sparkEmmiter!.zPosition = 1
            addChild(sparkEmmiter!)
            if mute != true {run(deathSound)}
            //TODO: Make the ball fade away
            return()
        }
        
        //If the ball is falling
        if player.physicsBody?.velocity.dy < 0 {
            
            //If the player hits the Platform
            if player.physicsBody?.velocity.dy < 0 && whichNode?.name == "NODE_PLATFORM" {
                
                
                //If the bottom point of the ball is above or equal to the top of the platform
                let playerSprite = SKSpriteNode(imageNamed: GameState.sharedInstance.player)
                playerSprite.setScale(scaleFactor)
                var ballBottom = CGFloat(player.position.y - playerSprite.size.height/2)
                
                let platformSprite = SKSpriteNode(imageNamed: "platform")
                platformSprite.setScale(scaleFactor)
                var platformTop = CGFloat(whichNode!.position.y + platformSprite.size.height/2)
                
                //If the ball is not directly connected
                if ballBottom < platformTop - 3 {return}
                
                let joint = SKPhysicsJointFixed.joint(withBodyA: player.physicsBody!, bodyB:whichNode!.physicsBody!, anchor:CGPoint(x: player.position.x, y: ballBottom))
                let moveScreen = SKAction.moveTo(y: -(player.position.y - 200), duration: 0.5)
                let moveBackround = SKAction.moveTo(y: -(player.position.y - 200)/5, duration: 0.5)
                let moveVortex = SKAction.moveTo(y: (player.position.y - scaleFactor*300), duration: 0.5)
                
                physicsWorld.add(joint)
                
                //Moves the Backround and player layer (to move the backround slower divide by 10)
                backgroundNode.run(moveBackround)
                foregroundNode.run(moveScreen)
                vortex.run(moveVortex)
                
                //Brings the player to the correct level in line with the platform (Corrects Glitch)
                let levelPlayer = SKAction.moveTo(y: platformTop + playerSprite.size.height/2, duration:TimeInterval(0.01))
                player.run(levelPlayer)
                
                //High Score Reached Notification
                if GameState.sharedInstance.score == GameState.sharedInstance.highScore && GameState.sharedInstance.highScore != 0 {
                    let scoreSound = SKAction.playSoundFileNamed("Score.wav", waitForCompletion: false)
                    let sparkEmmiter = SKEmitterNode(fileNamed: "Stars.sks")
                    sparkEmmiter!.position = CGPoint(x: player.position.x, y: contact.contactPoint.y)
                    sparkEmmiter!.particleLifetime = 1
                    sparkEmmiter!.zPosition = 1
                    addChild(sparkEmmiter!)
                    if mute != true {run(scoreSound)}
                }
                
                if GameState.sharedInstance.score == 4 {
                    //EasyGameCenter.reportAchievement(progress: 100.00, achievementIdentifier: "score_5points", addToExisting: true)
                }
                
                if GameState.sharedInstance.score == 19 {
                    //EasyGameCenter.reportAchievement(progress: 100.00, achievementIdentifier: "score_20points", addToExisting: true)
                }
                
                if GameState.sharedInstance.score == 49 {
                    //EasyGameCenter.reportAchievement(progress: 100.00, achievementIdentifier: "score_50points", addToExisting: true)
                }
                
                //Generate New Platform
                if GameState.sharedInstance.score > 98 {
                    platformGen()
                }
            }
        }
        updateHUD = other.collisionWithPlayer(player)
        
        //Update Score
        if lblScore.text < String(format: "%d", GameState.sharedInstance.score) {
            
            //animate text
            //lblScore.removeAllActions()
            //lblScoreBack.removeAllActions()
            //let scoreAction = SKAction.scaleBy(1.3, duration: 0.1)
            //let run = SKAction.runBlock { () -> Void in
                self.lblScore.text = String(format: "%d", GameState.sharedInstance.score)
            //}
            //let revertAction = SKAction.scaleTo(1, duration: 0.1)
            //let completeAction = SKAction.sequence([scoreAction,run,revertAction])
            //lblScore.runAction(completeAction)
            //lblScoreBack.runAction(completeAction)
        }

        // Update the HUD if necessary
        if updateHUD {
            lblStars.text = String(format: "= %d", GameState.sharedInstance.stars)
        }
    }
    
    //Time Update
    override func update(_ currentTime: TimeInterval) {
        
        //End if game is over
        if gameOver {return}
        
        if self.name == "pausedGame" {
            pauseNode.isHidden = false
            hudPause.isHidden = true
            isPaused = true
            self.name = "game"
        }
        
        //Raise the Vortex
        if player.physicsBody!.isDynamic {
            vortex.physicsBody?.velocity = CGVector(dx: vortex.physicsBody!.velocity.dx, dy: 60)
        }
        
        if isPaused == false {
            pauseNode.isHidden = true
            hudPause.isHidden = false
        }
        
        //Update Score
        lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        lblScoreBack.text = String(format: "%d", GameState.sharedInstance.score)
        
        // Remove game objects that have passed by
        foregroundNode.enumerateChildNodes(withName: "NODE_PLATFORM", using: {
            (node, stop) in
            let platform = node as! PlatformNode
            platform.checkNodeRemoval(self.player.position.y)
        })
        
        foregroundNode.enumerateChildNodes(withName: "NODE_STAR", using: {
            (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(self.player.position.y)
        })
        
        // Check if we've finished the level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        
        // Check if we've fallen too far
        if Int(player.position.y) < maxPlayerY - 400 {
            endGame()
        }
        
        if player.position.y < vortex.position.y {
            endGame()
        }
        
    }
    
    
} //endfile

