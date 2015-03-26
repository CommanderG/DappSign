//
//  DappsViewController.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/20/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappsInfo {
    internal var hashtag: PFObject?
    internal var dapps: [PFObject] = []
    
    init(hashtag: PFObject?, dapps: [PFObject]) {
        self.hashtag = hashtag
        self.dapps = dapps
    }
}

class DappsViewController: UIViewController {
    internal var dappsInfo: DappsInfo? = nil
    
    @IBOutlet weak var dappView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var dappsSwipesCountLabel: UILabel!
    
    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    var attachmentBehavior: UIAttachmentBehavior!
    
    var dappFonts = DappFonts()
    var dappColors = DappColors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let font = UIFont(name: "Exo-Regular", size: 18.0) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        if let font = UIFont(name: "Exo-Regular", size: 16.0) {
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [NSFontAttributeName: font],
                forState: .Normal
            )
        }
        
        self.shareOnFacebookButton.layer.cornerRadius = 8.0
        self.tweetThisCardButton.layer.cornerRadius = 8.0
        
        self.animator = UIDynamicAnimator(referenceView: view)
        self.snapBehavior = UISnapBehavior(
            item: self.dappView,
            snapToPoint: self.view.center
        )
        
        self.initTitle()
        self.initDappView()
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
                        if let currentDapp = self.dappsInfo?.dapps.first {
                            self.markDappAsSwiped(currentDapp, completion: {
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
                    
                    if self.dappsInfo?.dapps.count > 0 {
                        self.dappsInfo?.dapps.removeAtIndex(0)
                    }
                    
                    if self.dappsInfo?.dapps.count > 0 {
                        self.initDappView()
                    } else {
                        self.dappView.hidden = true
                        
                        delay(0.15) {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
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
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        let currentDapp = self.dappsInfo?.dapps.first
        
        if currentDapp == nil {
            return
        }
        
        let currentDappCardAsImage = self.dappView.toImage()
        
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
    
    // MARK: - Requests
    
    private func markDappAsSwiped(dapp: PFObject, completion: (succeeded: Bool, error: NSError?) -> Void) -> Void {
        let user = PFUser.currentUser()
        let dappsSwipedRelation = user.relationForKey(dappsSwipedRelationKey)
        
        dappsSwipedRelation.addObject(dapp)
        
        user.saveInBackgroundWithBlock {
            (succeeded: Bool, error: NSError!) -> Void in
            completion(succeeded: succeeded, error: error)
            
            if let dappTypeId = dapp["dappTypeId"] as? String {
                if dappTypeId != DappTypeId.Secondary.rawValue {
                    return
                }
                
                if let dappScore = dapp["dappScore"] as? Int {
                    dapp["dappScore"] = dappScore + 1
                } else {
                    dapp["dappScore"] = 2 // (undefined) + 1
                }
                
                dapp.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError!) -> Void in
                    if error != nil {
                        println(error)
                        
                        return
                    }
                })
            }
        }
    }
    
    // MARK: -
    
    private func initTitle() {
        if let dappsInfo = self.dappsInfo {
            if let title = self.dappsInfo?.hashtag?["name"] as? String {
                self.title = "#\(title)"
                
                return
            }
            
            if dappsInfo.dapps.count < 2 {
                self.title = "Dapp"
            } else if dappsInfo.dapps.count > 0 {
                self.title = "Dapps"
            }
        }
    }
    
    private func initDappView() {
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
        
        if self.dappsInfo?.dapps.count > 0 {
            if let dapp = self.dappsInfo?.dapps.first {
                if let dappScore = dapp["dappScore"] as Int? {
                    var text: String
                    
                    if dappScore == 1 {
                        text = "1 Dapp and counting"
                    } else {
                        text = "\(dappScore) Dapps and counting"
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
}
