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
    
    var animator : UIDynamicAnimator!
    var snapBehavior : UISnapBehavior!
    var attachmentBehavior : UIAttachmentBehavior?
    var originalLocation: CGPoint!
    var currentDappIndex = 0
    var dappFonts = DappFonts()
    var dappColors = DappColors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareOnFacebookButton.layer.cornerRadius = 8.0
        self.tweetThisCardButton.layer.cornerRadius = 8.0
        
        self.originalLocation = dappView.center
        self.animator = UIDynamicAnimator(referenceView: view)
        
        self.showCurrentDapp()
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - @IBActions
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func handleGesture(sender: AnyObject) {
        let location = sender.locationInView(view)
        let boxLocation = sender.locationInView(dappView)
        let myView = self.dappView
        //let originalLocation = dappView.center
        
        self.dappView.center = location
        
        if sender.state == UIGestureRecognizerState.Began {
            self.animator.removeBehavior(self.snapBehavior)
            
            let centerOffset = UIOffset(
                horizontal: boxLocation.x - CGRectGetMidX(myView.bounds),
                vertical: boxLocation.y - CGRectGetMidY(myView.bounds)
            )
            self.attachmentBehavior = UIAttachmentBehavior(
                item: myView,
                offsetFromCenter: centerOffset,
                attachedToAnchor: location
            )
            self.attachmentBehavior?.frequency = 0
            
            self.animator.addBehavior(attachmentBehavior)
        } else if sender.state == UIGestureRecognizerState.Changed {
            self.attachmentBehavior?.anchorPoint = location
        } else if sender.state == UIGestureRecognizerState.Ended {
            self.animator.removeBehavior(self.attachmentBehavior?)
            
            self.snapBehavior = UISnapBehavior(item: myView, snapToPoint: self.originalLocation)
            
            self.animator.addBehavior(self.snapBehavior)
            
            let translation = sender.translationInView(view)
            
            if self.currentDappIndex >= self.dappsInfo?.dapps.count {
                // Current Dapp is "No more DappSigns.". It doesn't exist on the server, so ignore it
                return
            }
            
            if translation.x > 100 {
                self.handleSwipe(.SwipeFromLeftToRight)
            } else if translation.x < -100 {
                self.handleSwipe(.SwipeFromRightToLeft)
            }
        }
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let currentDappCardAsImage = self.dappView.toImage()
        
        FacebookHelper.postImageToFacebook(currentDappCardAsImage,
            completion: {
                (success, error) -> Void in
                if success {
                    self.showAlertViewWithOKButtonAndMessage("The card has been successfully posted.")
                } else {
                    if error != nil {
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
                (success, error) -> Void in
                if success {
                    self.showAlertViewWithOKButtonAndMessage("The card has been successfully tweeted.")
                } else {
                    if error != nil {
                        self.showAlertViewWithOKButtonAndMessage("Failed to tweet the card. Error: \(error)")
                    } else {
                        self.showAlertViewWithOKButtonAndMessage("Failed to tweet the card. Unknown error.")
                    }
                }
        })
    }
    
    
    
    // MARK: -
    
    private func handleSwipe(swipe: Swipe) -> Void {
        var gravityDirection: CGVector
        
        switch swipe {
        case .SwipeFromLeftToRight:
            gravityDirection = CGVectorMake(10, -30)
        case .SwipeFromRightToLeft:
            gravityDirection = CGVectorMake(-10, 30)
        }
        
        self.markCurrentDappAsSwiped(swipe, {
            (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                self.animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [self.dappView])
                gravity.gravityDirection = gravityDirection
                
                self.animator.addBehavior(gravity)
                
                delay(0.3) {
                    ++self.currentDappIndex
                    
                    if self.currentDappIndex == self.dappsInfo?.dapps.count {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        self.showCurrentDapp()
                    }
                }
            } else {
                if error != nil {
                    println("Failed to mark current Dapp as swiped. Error: \(error!)")
                } else {
                    println("Failed to mark current Dapp as swiped. Unknown error")
                }
            }
        })
    }
    
    private func showCurrentDapp() {
        animator.removeAllBehaviors()
        
        snapBehavior = UISnapBehavior(item:dappView, snapToPoint: view.center)
        attachmentBehavior?.anchorPoint = view.center
        
        dappView.center = view.center ///uh......dunno
        
        
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        
        dappView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.dappView.transform = CGAffineTransformConcat(scale, translate)
        }
        
        self.updateDappView()
        
        dappView.hidden = false
    }
    
    private func updateDappView() -> Void {
        if currentDappIndex < self.dappsInfo?.dapps.count {
            if let dapp = self.dappsInfo?.dapps[self.currentDappIndex] {
                let dappFontName = dapp["dappFont"] as String!
                let dappBgColoName = dapp["dappBackgroundColor"] as String!
                
                self.dappTextView.text = dapp["dappStatement"] as String!
                self.dappTextView.font = dappFonts.dappFontBook[dappFontName]
                self.dappTextView.textColor = UIColor.whiteColor()
                self.dappTextView.backgroundColor = dappColors.dappColorWheel[dappBgColoName]
            }
        }
        
        self.scoreView.backgroundColor = self.dappTextView.backgroundColor
        self.logoView.backgroundColor = self.dappTextView.backgroundColor
    }
    
    private func markCurrentDappAsSwiped(swipe: Swipe, completion: (succeeded: Bool, error: NSError?) -> Void) -> Void {
        let user = PFUser.currentUser()
        let dappsSwipedRelation = user.relationForKey(dappsSwipedRelationKey)
        let currentDapp = self.dappsInfo?.dapps[self.currentDappIndex]
        
        dappsSwipedRelation.addObject(currentDapp)
        user.saveInBackgroundWithBlock {
            (succeeded: Bool, error: NSError!) -> Void in
            completion(succeeded: succeeded, error: error)
            
            if swipe != .SwipeFromLeftToRight {
                return
            }
            
            if currentDapp == nil {
                return
            }
            
            if let dappTypeId = currentDapp!["dappTypeId"] as? String {
                if dappTypeId != DappTypeId.Secondary.rawValue {
                    return
                }
                
                var dappScore = currentDapp!["dappScore"] as? Int
                
                if dappScore != nil  {
                    currentDapp!["dappScore"] = ++dappScore!
                } else {
                    currentDapp!["dappScore"] = 2 // (undefined) + 1
                }
                
                currentDapp!.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError!) -> Void in
                    if error != nil {
                        println(error)
                        
                        return
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(DappSwipedNotification,
                        object: currentDapp,
                        userInfo: nil
                    )
                })
            }
        }
    }
}
