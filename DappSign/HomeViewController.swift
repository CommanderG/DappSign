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
    
    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    
    var dapps: [PFObject] = []
    var dappsDownloader: DappsDownloader?
    var dappFonts = DappFonts()
    var dappColors = DappColors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            
            if swipedFromRightToLeft || swipedFromLeftToRight {
                self.animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [self.dappView])
                gravity.gravityDirection = CGVectorMake(0, 10)
                
                self.animator.addBehavior(gravity)
                
                delay(0.3) {
                    self.animator.removeAllBehaviors()
                    
                    self.attachmentBehavior.anchorPoint = self.view.center
                    self.dappView.center = self.view.center
                    
                    let scale = CGAffineTransformMakeScale(0.5, 0.5)
                    let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
                    
                    self.dappView.transform = CGAffineTransformConcat(scale, translate)
                    
                    if swipedFromLeftToRight {
                        if let currentDapp = self.dapps.first {
                            Requests.markDappAsSwiped(currentDapp,
                                user: PFUser.currentUser(),
                                completion: {
                                    (succeeded: Bool, error: NSError?) -> Void in
                                    if succeeded {
                                        println("Successfully marked Dapp with Id \(currentDapp.objectId) as swiped.")
                                        
                                        return
                                    }
                                    
                                    if let error = error {
                                        println("Failed to mark current Dapp as swiped. Error: \(error)")
                                    } else {
                                        println("Failed to mark current Dapp as swiped. Unknown error")
                                    }
                            })
                        }
                    }
                    
                    if self.dapps.count > 0 {
                        self.dapps.removeAtIndex(0)
                    }
                    
                    if self.dapps.count > 0 {
                        self.initDappView()
                    } else {
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
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let currentDappCardAsImage = self.dappView.toImage()
        
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
    
    @IBAction func tweetCurrentDappCard(sender: AnyObject) {
        let currentDappCardAsImage = self.dappView.toImage()
        
        TwitterHelper.tweetDappCardImage(currentDappCardAsImage,
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
            user["image"] = UIImage(data: data)
            
            user.save()
            
            FBRequestConnection.startForMeWithCompletionHandler({
                connection, result, error in
                if let resultDict = result as? NSDictionary {
                    let name = resultDict["name"] as String
                    
                    user["name"] = name
                    user["lowercaseName"] = name.lowercaseString
                    
                    user.save()
                }
            })
            
            user["dappScore"] = 0
            user.save()
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
    
    // MARK: -
    
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
                self.dappTextView.text = dapp["dappStatement"] as? String
                
                if let dappFontName = dapp["dappFont"] as? String {
                    self.dappTextView.font = dappFonts.dappFontBook[dappFontName]
                }
                
                self.dappTextView.textColor = UIColor.whiteColor()
                
                if let dappBgColoName = dapp["dappBackgroundColor"] as? String {
                    self.dappTextView.backgroundColor = dappColors.dappColorWheel[dappBgColoName]
                }
            }
        } else {
            self.dappTextView.text = "No more DappSigns. Feel free to submit your own!"
            
            if let font = dappFonts.dappFontBook["exo"] {
                self.dappTextView.font = font
            }
            
            self.dappTextView.textColor = UIColor.whiteColor()
            self.dappTextView.backgroundColor = dappColors.dappColorWheel["midnightBlue"]
        }
        
        self.scoreView.backgroundColor = self.dappTextView.backgroundColor
        self.logoView.backgroundColor = self.dappTextView.backgroundColor
    }
}
