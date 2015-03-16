//
//  HomeViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 2/28/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    enum Swipe {
        case SwipeFromLeftToRight
        case SwipeFromRightToLeft
    }
    
    //storyboard elements
//    @IBOutlet weak var dappView: UIView!
//    @IBOutlet weak var dappHeaderView: UIView!
//    @IBOutlet weak var dappFooterView: UIView!
//    @IBOutlet weak var dappCounterView: UIView!
//    @IBOutlet weak var dappLogoView: UIView!
//    @IBOutlet weak var dappTextView: UITextView!
//    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var dappView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var congressImageView: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton: UIButton!
    
    var user = PFUser.currentUser()
    
    //array to be loaded from parse
    var dapps: NSMutableArray! = NSMutableArray()
    var currentDappIndex = 0
    
    //dapp Colors and fonts
    var dappColors = DappColors()
    var dappFonts = DappFonts()
    
    //animator behavior variables
    var originalLocation: CGPoint!
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior?
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    let dappsSwipedRelationKey = "dappsSwiped"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareOnFacebookButton.layer.cornerRadius = 8.0
        self.tweetThisCardButton.layer.cornerRadius = 8.0
        
        if (PFUser.currentUser() != nil && user["name"] == nil){
            var FBSession = PFFacebookUtils.session()
            var accessToken = FBSession.accessTokenData.accessToken
            
            let url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources+1&access_token="+accessToken)
            
            let urlRequest = NSURLRequest(URL: url!)
            
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                response, data, error in
                let image = UIImage(data: data)
                
                self.user["image"] = data
                self.user.save()
                
                FBRequestConnection.startForMeWithCompletionHandler({
                    connection, result, error in
                    if let resultDict = result as? NSDictionary {
                        self.user["name"] = resultDict["name"]
                        self.user.save()
                    }
                })
                
            })
            self.user["dappScore"] = 0
            self.user.save()
        }
        
        originalLocation = dappView.center
        animator = UIDynamicAnimator(referenceView: view)
        
        dappView.hidden = true
        
        self.downloadDappsFromParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func composeButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("showAddDappViewController", sender: self)
    }
    
    @IBAction func handleGesture(sender: AnyObject) {
        let location = sender.locationInView(view)
        let boxLocation = sender.locationInView(dappView)
        let myView = dappView
        //let originalLocation = dappView.center
        
        dappView.center = location
        
        if sender.state == UIGestureRecognizerState.Began {
            animator.removeBehavior(snapBehavior)
            
            let centerOffset = UIOffset(
                horizontal: boxLocation.x - CGRectGetMidX(myView.bounds),
                vertical: boxLocation.y - CGRectGetMidY(myView.bounds)
            )
            attachmentBehavior = UIAttachmentBehavior(
                item: myView,
                offsetFromCenter: centerOffset,
                attachedToAnchor: location
            )
            attachmentBehavior?.frequency = 0
            
            animator.addBehavior(attachmentBehavior)
        } else if sender.state == UIGestureRecognizerState.Changed {
            attachmentBehavior?.anchorPoint = location
        } else if sender.state == UIGestureRecognizerState.Ended {
            animator.removeBehavior(attachmentBehavior)
            
            snapBehavior = UISnapBehavior(item: myView, snapToPoint: originalLocation)
            
            animator.addBehavior(snapBehavior)
            
            let translation = sender.translationInView(view)
            
            if currentDappIndex >= dapps.count {
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
    
    private func updateDappView() -> Void {
        if currentDappIndex < dapps.count {
            if let dapp = dapps[currentDappIndex] as? PFObject {
                let dappFontName = dapp["dappFont"] as String!
                let dappBgColoName = dapp["dappBackgroundColor"] as String!
                
                self.dappTextView.text = dapp["dappStatement"] as String!
                self.dappTextView.font = dappFonts.dappFontBook[dappFontName]
                self.dappTextView.textColor = UIColor.whiteColor()
                self.dappTextView.backgroundColor = dappColors.dappColorWheel[dappBgColoName]
            }
        } else {
            self.dappTextView.text = "No more DappSigns. Feel free to submit your own!"
            self.dappTextView.font  = dappFonts.dappFontBook["exo"]!
            self.dappTextView.textColor = UIColor.whiteColor()
            self.dappTextView.backgroundColor = dappColors.dappColorWheel["midnightBlue"]
        }
        
        self.scoreView.backgroundColor = self.dappTextView.backgroundColor
        self.logoView.backgroundColor = self.dappTextView.backgroundColor
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
    
    private func downloadDappsFromParse() {
        self.downloadDapps(.Primary,
            completion: {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error != nil {
                    println(error)
                    
                    self.currentDappIndex = 0
                    
                    self.showCurrentDapp()
                    
                    return
                }
                
                self.dapps.removeAllObjects()
                
                self.dapps = NSMutableArray(array: objects)
                
                if self.dapps.count > 0 {
                    self.currentDappIndex = 0
                    
                    self.showCurrentDapp()
                }
                
                self.downloadDapps(.Secondary,
                    completion: {
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error != nil {
                            println(error)
                            
                            self.currentDappIndex = 0
                            
                            self.showCurrentDapp()
                            
                            return
                        }
                        
                        if objects.count > 0 {
                            var shouldShowCurrentDapp = false;
                            
                            if self.dapps.count == 0 {
                                self.currentDappIndex = 0
                                
                                shouldShowCurrentDapp = true
                            }
                            
                            var dapps = objects as [PFObject]
                            
                            sort(&dapps, {
                                (dapp1: PFObject, dapp2: PFObject) -> Bool in
                                return dapp1["dappScore"] as? Int > dapp2["dappScore"] as? Int
                            })
                            
                            for dapp in dapps {
                                self.dapps.addObject(dapp)
                            }
                            
                            if shouldShowCurrentDapp {
                                self.showCurrentDapp()
                            }
                        } else if self.dapps.count == 0 {
                            self.currentDappIndex = 0
                            
                            self.showCurrentDapp()
                        }
                })
        })
    }
    
    private func downloadDapps(dappType: DappType, completion: (objects: [AnyObject]!, error: NSError!) -> Void) -> Void {
        let user = PFUser.currentUser()
        let dappsSwipedRelation = user.relationForKey(self.dappsSwipedRelationKey)
        
        // this query will return first 100 Dapps (default limit) swiped by the user
        // this objects are stored in the User class in 'dappsSwiped' relation
        let dappsSwipedRelationQuery = dappsSwipedRelation.query()
        
        let predicate = DappQueriesBuilder.predicateForAllDapsOfType(dappType)
        
        if predicate == nil {
            let error = NSError(
                domain: "Failed to create predicate for \(dappType)",
                code: 0,
                userInfo: nil
            )
            
            completion(objects: nil, error: error)
            
            return
        }
        
        let allDappsQuery = PFQuery(
            className: "Dapps",
            predicate: predicate
        )
        allDappsQuery.limit = 1000
        
        // here we say that from that 100 Dapps we want only these which hasn't been swiped by the user
        allDappsQuery.whereKey("objectId",
            doesNotMatchKey: "objectId",
            inQuery: dappsSwipedRelationQuery
        )
        
        // don't download Dapps created by the user
        allDappsQuery.whereKey("userid", notEqualTo: user.objectId)
        
        if dappType == .Primary {
            allDappsQuery.orderByAscending("createdAt")
        }
        
        allDappsQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            completion(objects: objects, error: error)
        }
    }
    
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
                    
                    if self.currentDappIndex == self.dapps.count {
                        self.downloadDappsFromParse()
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
    
    private func markCurrentDappAsSwiped(swipe: Swipe, completion: (succeeded: Bool, error: NSError?) -> Void) -> Void {
        let user = PFUser.currentUser()
        let dappsSwipedRelation = user.relationForKey(self.dappsSwipedRelationKey)
        let currentDapp = self.dapps[currentDappIndex] as PFObject
        
        dappsSwipedRelation.addObject(currentDapp)
        user.saveInBackgroundWithBlock {
            (succeeded: Bool, error: NSError!) -> Void in
            completion(succeeded: succeeded, error: error)
            
            if swipe != .SwipeFromLeftToRight {
                return
            }
            
            if let dappTypeId = currentDapp["dappTypeId"] as? String {
                if dappTypeId != DappTypeId.Secondary.rawValue {
                    return
                }
                
                var dappScore = currentDapp["dappScore"] as? Int
                
                if dappScore != nil  {
                    currentDapp["dappScore"] = ++dappScore!
                } else {
                    currentDapp["dappScore"] = 2 // (undefined) + 1
                }
                
                currentDapp.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError!) -> Void in
                    if error != nil {
                        println(error)
                        
                        return
                    }
                })
            }
        }
    }
}
