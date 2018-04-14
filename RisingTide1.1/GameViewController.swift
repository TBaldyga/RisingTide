//
//  GameViewController.swift
//  risingtide
//
//  Created by Tim Baldyga on 7/21/15.
//  Copyright (c) 2015 Tim Baldyga. All rights reserved.
//

import UIKit
import SpriteKit
import Social


class GameViewController: UIViewController, ADBannerViewDelegate, EGCDelegate {
    
    func loadAds() {
        adBannerView = ADBannerView(frame: CGRect.zero)
        adBannerView.delegate = self
        adBannerView.isHidden = true
        view.addSubview(adBannerView)
    }
    
    func pauseGameScene() {
        let skView = self.view as! SKView
        if skView.scene?.name == "game" {
            skView.scene!.name = "pausedGame"
            //skView.paused = true
            //skView.scene!.paused = true
        }
    }
    
    //Share Button
    func shareButton() {
        var sharingItems = [AnyObject]()
        
        sharingItems.append("Check out Rising Tide! for iOS: http://appsto.re/us/hZt58.i" as AnyObject)
        
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0);
        self.view!.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        let image:UIImage = UIImage(named:"shareIcon")!
        
        UIGraphicsEndImageContext();
        
        sharingItems.append(image)
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        
        var barButtonItem: UIBarButtonItem! = UIBarButtonItem()
        
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop,UIActivityType.addToReadingList,UIActivityType.assignToContact,UIActivityType.postToTencentWeibo,UIActivityType.postToVimeo,UIActivityType.print,UIActivityType.saveToCameraRoll,UIActivityType.postToWeibo]
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //Twitter Share
    func showTweetSheet() {
        let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweetSheet?.completionHandler = {
            result in
            switch result {
            case SLComposeViewControllerResult.cancelled:
                //Add code to deal with it being cancelled
                break
                
            case SLComposeViewControllerResult.done:
                //Add code here to deal with it being completed
                //Remember that dimissing the view is done for you, and sending the tweet to social media is automatic too. You could use this to give in game rewards?
                //EasyGameCenter.reportAchievement(progress: 100.00, achievementIdentifier: "share_twitter", addToExisting: true)
                break
            }
        }
        
        tweetSheet?.setInitialText("Don't fall behind! Check out #RisingTide on iOS and try to beat my high score of \(GameState.sharedInstance.highScore)!") //The default text in the tweet
        //tweetSheet.addImage(UIImage(named: "play.png")) //Add an image if you like?
        tweetSheet?.add(URL(string: "http://appsto.re/us/hZt58.i")) //A url which takes you into safari if tapped on
        
        self.present(tweetSheet!, animated: false, completion: {
            //Optional completion statement
        })
    }
    
    //Facebook Share
    func showFacebook() {
        let faceBook = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        faceBook?.completionHandler = {
            result in
            switch result {
            case SLComposeViewControllerResult.cancelled:
                //Add code to deal with it being cancelled
                break
                
            case SLComposeViewControllerResult.done:
                //Add code here to deal with it being completed
                //Remember that dimissing the view is done for you, and sending the tweet to social media is automatic too. You could use this to give in game rewards?
                //EasyGameCenter.reportAchievement(progress: 100.00, achievementIdentifier: "share_facebook", addToExisting: true)
                break
            }
        }
        
        faceBook?.setInitialText("Hey, don't fall behind! I am loving this new game, Rising Tide!, for iOS. Check it out and see if you can beat my High Score!") //The default text in the tweet
        //faceBook.addImage(UIImage(named: "play.png")) //Add an image if you like?
        faceBook?.add(URL(string: "http://appsto.re/us/hZt58.i")) //A url which takes you into safari if tapped on
        
        self.present(faceBook!, animated: false, completion: {
            //Optional completion statement
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EGC.sharedInstance(self)
        
        let skView = self.view as! SKView
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = false
        
        let start = StartScene(size: skView.bounds.size)
        let gameScene = GameScene(size: skView.bounds.size)
        let endScene = EndGameScene(size: skView.bounds.size)
        
        start.scaleMode = .aspectFit
        skView.presentScene(start)
        
        loadAds()
        
        //Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showTweetSheet), name: NSNotification.Name(rawValue: "com.twitter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showFacebook), name: NSNotification.Name(rawValue: "com.facebook"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.shareButton), name: NSNotification.Name(rawValue: "shareButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.pauseGameScene), name: NSNotification.Name(rawValue: "PauseGameScene"), object: nil)
        
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //iAd
    func bannerViewWillLoadAd(_ banner: ADBannerView!) {
        
        print("Ad about to load")
        
    }
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
        
        adBannerView.isHidden = false
        print("Displaying the Ad")
        
    }
    
    func bannerViewActionDidFinish(_ banner: ADBannerView!) {
        
        //unPause
        let skView = self.view as! SKView
        skView.isPaused = false
        print("Close the Ad")
        
    }
    
    func bannerViewActionShouldBegin(_ banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        
        //pause game here
        let skView = self.view as! SKView
        skView.isPaused = true
        
        print("Leave the application to the Ad")
        return true
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        
        //move off bounds when add didnt load
        
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height + view.bounds.size.height)
        
        print("Ad is not available")
        
    }
    
}
