//
//  HomeViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 2/28/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

internal let DappSwipedNotification = "dappSwipedNotification"
internal let dappsSwipedRelationKey = "dappsSwiped"
internal let dappsDappedRelationKey = "dappsDapped"



internal enum Swipe {
    case SwipeFromLeftToRight
    case SwipeFromRightToLeft
}

class HomeViewController: UIViewController {
    @IBOutlet weak var dappSignView: DappSignView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var dappScoreLabel: UILabel!
    
    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    
    var dapps: [PFObject] = []
    var dappsDownloader: DappsDownloader?
    var dappFonts = DappFonts()
    var dappColors = DappColors()
    
    var timer: NSTimer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.dappTextView.TextAlignment
        
        self.dappScoreLabel.text = nil;
        
        self.animator = UIDynamicAnimator(referenceView: view)
        self.snapBehavior = UISnapBehavior(
            item: self.dappSignView,
            snapToPoint: self.view.center
        )
        
        self.dappSignView.hidden = true
        
        if PFUser.currentUser() == nil {
            self.profileButton.hidden = true
        }
        
        self.updateUserInformation()
        self.downloadDapps()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("handleDappSwipedNotification:"),
            name: DappSwipedNotification,
            object: nil
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(
            1.0,
            target: self,
            selector: Selector("updateDappScore"),
            userInfo: nil,
            repeats: true
        )
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.timer?.invalidate()
    }
    
    // MARK: - @IBActions
    
    @IBAction func handleSwipe(sender: AnyObject) {
        let panGestureRecognizer = sender as! UIPanGestureRecognizer
        
        if panGestureRecognizer.state == .Began {
            self.animator.removeBehavior(self.snapBehavior)
            
            let location = panGestureRecognizer.locationInView(self.dappSignView)
            let centerOffset = UIOffset(
                horizontal: location.x - CGRectGetMidX(self.dappSignView.bounds),
                vertical: location.y - CGRectGetMidY(self.dappSignView.bounds)
            )
            
            self.attachmentBehavior = UIAttachmentBehavior(
                item: self.dappSignView,
                offsetFromCenter: centerOffset,
                attachedToAnchor: self.dappSignView.center
            )
            self.attachmentBehavior.frequency = 0.0
            
            self.animator.addBehavior(self.attachmentBehavior)
        } else if panGestureRecognizer.state == .Changed {
            let location = panGestureRecognizer.locationInView(self.view)
            
            self.attachmentBehavior.anchorPoint = location
        } else if panGestureRecognizer.state == .Ended {
            self.animator.removeBehavior(self.attachmentBehavior)
            self.animator.addBehavior(self.snapBehavior)
            
            let translation = panGestureRecognizer.translationInView(self.view)
            let swipedFromRightToLeft = translation.x < -150.0
            let swipedFromLeftToRight = translation.x > 150.0
            
            if !swipedFromRightToLeft && !swipedFromLeftToRight {
                return
            }
            
            self.animator.removeAllBehaviors()
            
            var gravity = UIGravityBehavior(items: [self.dappSignView])
            
            if swipedFromLeftToRight {
                gravity.gravityDirection = CGVectorMake(0, -10)
            } else {
                gravity.gravityDirection = CGVectorMake(0, 10)
            }
            
            self.animator.addBehavior(gravity)
            
            delay(0.3) {
                self.animator.removeAllBehaviors()
                
                self.attachmentBehavior.anchorPoint = self.view.center
                self.dappSignView.center = self.view.center
                
                let scale = CGAffineTransformMakeScale(0.5, 0.5)
                let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
                
                self.dappSignView.transform = CGAffineTransformConcat(scale, translate)
                
                if let currentDapp = self.dapps.first {
                    self.sendRequestsForDapp(
                        currentDapp,
                        dapped: swipedFromLeftToRight
                    )
                }
                
                if self.dapps.count > 0 {
                    self.dapps.removeAtIndex(0)
                }
                
                self.initDappView()
                
                if self.dapps.count == 0 {
                    self.downloadDapps()
                }
                
                spring(0.5) {
                    let scale = CGAffineTransformMakeScale(1.0, 1.0)
                    let translate = CGAffineTransformMakeTranslation(0.0, 0.0)
                    
                    self.dappSignView.transform = CGAffineTransformConcat(scale, translate)
                }
            }
        }
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let currentDappCardAsImage = self.dappSignView.toImage()
        let currentDapp = self.dapps.first
        
        if currentDapp == nil {
            return
        }
        
        if let currentDapp = self.dapps.first {
            FacebookHelper.postImageToFacebook(currentDappCardAsImage,
                dapp: currentDapp,
                completion: {
                    (success: Bool, error: NSError?) -> Void in
                    if success {
                        self.showAlertViewWithOKButtonAndMessage("The card has been successfully posted.")
                    } else {
                        if let error = error {
                            self.showAlertViewWithOKButtonAndMessage("Failed to post the card. Error: \(error)")
                        } else {
                            self.showAlertViewWithOKButtonAndMessage("Failed to post the card. Unknown error.")
                        }
                    }
            })
        }
    }
    
    @IBAction func tweetCurrentDappCard(sender: AnyObject) {
        let currentDappCardAsImage = self.dappSignView.toImage()
        let currentDapp = self.dapps.first
        
        if currentDapp == nil {
            return
        }
        
        TwitterHelper.tweetDapp(currentDapp!,
            image: currentDappCardAsImage,
            completion: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    self.showAlertViewWithOKButtonAndMessage("The card has been successfully tweeted.")
                } else {
                    if let error = error {
                        self.showAlertViewWithOKButtonAndMessage("Failed to tweet the card. Error: \(error)")
                    } else {
                        self.showAlertViewWithOKButtonAndMessage("Failed to tweet the card. Unknown error.")
                    }
                }
        })
    }
    
    // MARK: - 
    
    private func sendRequestsForDapp(dapp: PFObject, dapped: Bool) {
        let currentUser = PFUser.currentUser()
        
        Requests.addDappToDappsSwipedArray(dapp, user: currentUser, completion: {
            (succeeded: Bool, error: NSError?) -> Void in
            if !succeeded {
                if let error = error {
                    println(error)
                }
                
                return
            }
            
            if !dapped {
                return
            }
            
            Requests.addDappToDappsDappedArray(dapp, user: currentUser, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        println("Failed to add dapp with ID \(dapp.objectId) to 'dappsDapped' array. Error = \(error.localizedDescription)")
                    } else {
                        println("Failed to add dapp with ID \(dapp.objectId) to 'dappsDapped' array. Unknown error.")
                    }
                }
            })
            
            Requests.incrementScoreOfTheDapp(dapp, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        println(error)
                    }
                }
            })
            
            if let userId = dapp["userid"] as? String {
                Requests.incrementDappScoreForUserWithId(userId, completion: {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if !succeeded {
                        if let error = error {
                            println("Failed to update dappScore for user with id \(userId). Error: \(error.localizedDescription)")
                        } else {
                            println("Failed to update dappScore for user with id \(userId). Unknown error")
                        }
                    }
                })
            }
            
            let currentUserId = PFUser.currentUser().objectId
            
            Requests.incrementDappScoreForUserWithId(currentUserId, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        println(error.localizedDescription)
                    }
                }
            })
        })
    }
    
    // MARK: - Requests
    
    private func updateUserInformation() {
        var user = PFUser.currentUser()
        
        if user == nil {
            return
        }
        
        let userName = user["name"] as? String
        
        if userName != nil {
            return
        }
        
        let FBSession = PFFacebookUtils.session()
        let accessToken = FBSession.accessTokenData.accessToken
        
        let url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources+1&access_token=\(accessToken)")
        let urlRequest = NSURLRequest(URL: url!)
        let queue = NSOperationQueue.mainQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            user["image"] = data
            
            user.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    println("Successfully saved user's image.")
                } else {
                    println("Failed to save user's image.")
                    println("Errro: \(error)")
                }
            })
            
            FBRequestConnection.startForMeWithCompletionHandler({
                connection, result, error in
                if let resultDict = result as? NSDictionary {
                    let name = resultDict["name"] as! String
                    
                    user["name"] = name
                    user["lowercaseName"] = name.lowercaseString
                    
                    user.saveInBackgroundWithBlock({
                        (succeeded: Bool, error: NSError!) -> Void in
                        if succeeded {
                            println("Successfully saved user's name.")
                        } else {
                            println("Failed to save user's name.")
                            println("Errro: \(error)")
                        }
                    })
                }
            })
            
            user["dappScore"] = 0
            
            user.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    println("Successfully set user's dappScore to 0.")
                } else {
                    println("Failed to set user's dappScore to 0.")
                    println("Errro: \(error)")
                }
            })
        }
    }

    private func downloadDapps() {
        self.downloadPrimaryDappsWithSuccessClosure {
            () -> Void in
            self.downloadSecondaryDapps()
        }
    }
    
    private func downloadPrimaryDappsWithSuccessClosure(success: () -> Void) {
        let user = PFUser.currentUser()
        
        self.dappsDownloader = DappsDownloader(type: .Primary)
        
        self.dappsDownloader?.downloadDappsNotSwipedByUser(user,
            completion: {
                (dapps: [PFObject], error: NSError!) -> Void in
                if error != nil {
                    println(error)
                    
                    self.initDappView()
                    
                    return
                }
                
                self.dapps = dapps
                
                if self.dapps.count > 0 {
                    self.initDappView()
                }
                
                success()
        })
    }

    private func downloadSecondaryDapps() {
        let user = PFUser.currentUser()
        
        self.dappsDownloader = DappsDownloader(type: .Secondary)
        
        self.dappsDownloader?.downloadDappsNotSwipedByUser(user, completion: {
            (dapps: [PFObject], error: NSError!) -> Void in
            if error != nil {
                println(error)
                
                self.initDappView()
                
                return
            }
            
            if dapps.count > 0 {
                var shouldShowCurrentDapp = false;
                
                if self.dapps.count == 0 {
                    shouldShowCurrentDapp = true
                }
                
                var sortedDapps = dapps
                
                sort(&sortedDapps, {
                    (dapp1: PFObject, dapp2: PFObject) -> Bool in
                    return dapp1["dappScore"] as? Int > dapp2["dappScore"] as? Int
                })
                
                for dapp in sortedDapps {
                    self.dapps.append(dapp)
                }

                if shouldShowCurrentDapp {
                    self.initDappView()
                }
            } else if self.dapps.count == 0 {
                self.initDappView()
            }
        })
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            let profileNC = segue.destinationViewController as! UINavigationController
            
            if let profileVC = profileNC.viewControllers.first as? ProfileViewController {
                profileVC.user = PFUser.currentUser()
            }
        }
    }
    
    // MARK: - Timer
    
    func updateDappScore() {
        let currentUser = PFUser.currentUser()
        
        Requests.downloadDappScoreForUserWithId(currentUser.objectId, completion: {
            (dappScore: Int?, error: NSError?) -> Void in
            if error != nil {
                println(error)
                
                self.dappScoreLabel.text = nil
                
                return
            }
            
            if let dappScore = dappScore {
                if dappScore == 1 {
                    self.dappScoreLabel.text = "1 Dapp"
                } else {
                    self.dappScoreLabel.text = "\(dappScore) Dapp"
                }
            }
        })
    }
    
    // MARK: -
    
    internal func handleDappSwipedNotification(notification: NSNotification) {
        if let dappId = notification.object as? String {
            if self.dapps.first?.objectId == dappId {
                self.dapps.removeAtIndex(0)
                
                self.initDappView()
            } else {
                self.dapps = self.dapps.filter({ $0.objectId != dappId })
            }
        }
    }
    
    private func initDappView() {
        self.dappSignView.hidden = false
        
        self.perform_only_one_time() {
            let scale = CGAffineTransformMakeScale(0.5, 0.5)
            let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
            
            self.dappSignView.transform = CGAffineTransformConcat(scale, translate)
            
            spring(0.5) {
                let scale = CGAffineTransformMakeScale(1, 1)
                let translate = CGAffineTransformMakeTranslation(0, 0)
                
                self.dappSignView.transform = CGAffineTransformConcat(scale, translate)
            }
        }
        
        let dapp = dapps.first
        
        self.dappSignView.showDapp(dapp)
        
        if let dapp_ = dapp, userId = dapp_["userid"] as? String {
            let userQuery = PFUser.query()
            
            userQuery.whereKey("objectId", equalTo: userId)
            userQuery.findObjectsInBackgroundWithBlock({
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    if let user = objects.first as? PFObject? {
                        self.dappSignView.showUserInfo(user)
                    }
                } else {
                    println(error)
                }
            })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
