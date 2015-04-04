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

internal enum Swipe {
    case SwipeFromLeftToRight
    case SwipeFromRightToLeft
}

class HomeViewController: UIViewController {
    @IBOutlet weak var dappView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var dappsSwipesCountLabel: UILabel!
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
        
        self.dappScoreLabel.text = nil;
        
        self.animator = UIDynamicAnimator(referenceView: view)
        self.snapBehavior = UISnapBehavior(
            item: self.dappView,
            snapToPoint: self.view.center
        )
        
        self.dappView.hidden = true
        
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
        let panGestureRecognizer = sender as UIPanGestureRecognizer
        
        if panGestureRecognizer.state == .Began {
            self.animator.removeBehavior(self.snapBehavior)
            
            let location = panGestureRecognizer.locationInView(self.dappView)
            let centerOffset = UIOffset(
                horizontal: location.x - CGRectGetMidX(self.dappView.bounds),
                vertical: location.y - CGRectGetMidY(self.dappView.bounds)
            )
            
            self.attachmentBehavior = UIAttachmentBehavior(
                item: self.dappView,
                offsetFromCenter: centerOffset,
                attachedToAnchor: self.dappView.center
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
            
            var gravity = UIGravityBehavior(items: [self.dappView])
            
            if swipedFromLeftToRight {
                gravity.gravityDirection = CGVectorMake(0, -10)
            } else {
                gravity.gravityDirection = CGVectorMake(0, 10)
            }
            
            self.animator.addBehavior(gravity)
            
            delay(0.3) {
                self.animator.removeAllBehaviors()
                
                self.attachmentBehavior.anchorPoint = self.view.center
                self.dappView.center = self.view.center
                
                let scale = CGAffineTransformMakeScale(0.5, 0.5)
                let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
                
                self.dappView.transform = CGAffineTransformConcat(scale, translate)
                
                if let currentDapp = self.dapps.first {
                    self.sendRequestsForDapp(
                        currentDapp,
                        swipedFromLeftToRight: swipedFromLeftToRight
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
                    
                    self.dappView.transform = CGAffineTransformConcat(scale, translate)
                }
            }
        }
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let currentDappCardAsImage = self.dappView.toImage()
        
        if let currentDapp = self.dapps.first {
            FacebookHelper.postImageToFacebook(currentDappCardAsImage,
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
        let currentDappCardAsImage = self.dappView.toImage()
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
    
    private func sendRequestsForDapp(dapp: PFObject, swipedFromLeftToRight: Bool) {
        let currentUser = PFUser.currentUser()
        
        Requests.addDappToDappsSwipedArray(dapp, user: currentUser, completion: {
            (succeeded: Bool, error: NSError?) -> Void in
            if !succeeded {
                if let error = error {
                    println(error)
                }
                
                return
            }
            
            if !swipedFromLeftToRight {
                return
            }
            
            Requests.incrementScoreOfTheDapp(dapp, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        println(error)
                    }
                }
            })
            
            if let userId = dapp["userid"] as String? {
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
                    let name = resultDict["name"] as String
                    
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
        
        self.dappsDownloader?.downloadDappsNotSwipedByUser(user,
            completion: {
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
            let profileNC = segue.destinationViewController as UINavigationController
            
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
        if let dappId = notification.object as String? {
            if self.dapps.first?.objectId == dappId {
                self.dapps.removeAtIndex(0)
                
                self.initDappView()
            } else {
                self.dapps = self.dapps.filter({ $0.objectId != dappId })
            }
        }
    }
    
    private func initDappView() {
        self.dappView.hidden = false
        
        self.perform_only_one_time() {
            let scale = CGAffineTransformMakeScale(0.5, 0.5)
            let translate = CGAffineTransformMakeTranslation(0, -200)
            
            self.dappView.transform = CGAffineTransformConcat(scale, translate)
            
            spring(0.5) {
                let scale = CGAffineTransformMakeScale(1, 1)
                let translate = CGAffineTransformMakeTranslation(0, 0)
                
                self.dappView.transform = CGAffineTransformConcat(scale, translate)
            }
        }
        
        if dapps.count > 0 {
            if let dapp = dapps.first {
                if let dappScore = dapp["dappScore"] as Int? {
                    var text: String
                    
                    if dappScore == 1 {
                        text = "1 Dapp and counting"
                    } else {
                        text = "\(dappScore) Dapp and counting"
                    }
                    
                    self.dappsSwipesCountLabel.text = text
                } else {
                    self.dappsSwipesCountLabel.text = nil
                }
                
                self.dappTextView.text = dapp["dappStatement"] as? String
                
                if let dappFontName = dapp["dappFont"] as? String {
                    self.dappTextView.font = dappFonts.dappFontBook[dappFontName]
                }
                
                self.dappTextView.textColor = UIColor.whiteColor()
                
                if let dappBgColoName = dapp["dappBackgroundColor"] as? String {
                    self.dappTextView.backgroundColor = dappColors.dappColorWheel[dappBgColoName]
                }
                
                self.usernameLabel.text = nil
                self.userProfileImageView.image = nil
                
                if let userId = dapp["userid"] as String? {
                    let userQuery = PFUser.query()
                    
                    userQuery.whereKey("objectId", equalTo: userId)
                    
                    userQuery.findObjectsInBackgroundWithBlock({
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error != nil {
                            println(error)
                            
                            return
                        }
                        
                        if let user = objects.first as PFObject? {
                            self.usernameLabel.text = user["name"] as String?
                            self.userProfileImageView.image = UIImage(data: user["image"] as NSData)
                        } else {
                            self.usernameLabel.text = nil
                            self.userProfileImageView.image = nil
                        }
                    })
                }
            }
        } else {
            self.dappsSwipesCountLabel.text = nil
            self.dappTextView.text = "No more DappSigns. Feel free to submit your own!"
            
            if let font = dappFonts.dappFontBook["exo"] {
                self.dappTextView.font = font
            }
            
            self.dappTextView.textColor = UIColor.whiteColor()
            self.dappTextView.backgroundColor = dappColors.dappColorWheel["midnightBlue"]
            self.usernameLabel.text = nil
            self.userProfileImageView.image = nil
        }
        
        self.scoreView.backgroundColor = self.dappTextView.backgroundColor
        self.logoView.backgroundColor = self.dappTextView.backgroundColor
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
