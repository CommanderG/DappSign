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
    @IBOutlet weak var dappStatementLabel: UILabel!
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
        let panGestureRecognizer = sender as! UIPanGestureRecognizer
        
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
            
            let gravity = UIGravityBehavior(items: [self.dappView])
            
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
                
                if let currentDapp = self.dappsInfo?.dapps.first {
                    let currentUser = PFUser.currentUser()
                    
                    Requests.addDappToDappsSwipedArray(currentDapp, user: currentUser, completion: {
                        (succeeded: Bool, error: NSError?) -> Void in
                        if succeeded {
                            if swipedFromLeftToRight {
                                Requests.incrementScoreOfTheDapp(currentDapp, completion: {
                                    (succeeded: Bool, error: NSError?) -> Void in
                                    if !succeeded {
                                        if let error = error {
                                            print(error)
                                        }
                                    }
                                })
                            }
                        } else {
                            if let error = error {
                                print(error)
                            }
                        }
                    })
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
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        guard let dapp = self.dappsInfo?.dapps.first else {
            return
        }
        
        FacebookHelper.shareDapp(dapp, viewController: self) {
            (message: String?) in
            if let message = message {
                self.showAlertViewWithOKButtonAndMessage(message)
            }
        }
    }
    
    @IBAction func tweetCurrentDappCard(sender: AnyObject) {
        if let currentDapp = self.dappsInfo?.dapps.first {
            TwitterHelper.tweetDapp(currentDapp,
                completion: {
                    (success: Bool, error: NSError?) -> Void in
                    if success {
                        self.showAlertViewWithOKButtonAndMessage(
                            "The card has been successfully tweeted."
                        )
                    } else {
                        if let error = error {
                            self.showAlertViewWithOKButtonAndMessage(
                                "Failed to tweet the card. Error: \(error)"
                            )
                        } else {
                            self.showAlertViewWithOKButtonAndMessage(
                                "Failed to tweet the card. Unknown error."
                            )
                        }
                    }
            })
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
                self.title = "Dapp"
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
                if let dappScore = dapp["dappScore"] as? Int {
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
                
                self.dappStatementLabel.text = dapp["dappStatement"] as? String
                
                if let fontName = DappHelper.getFontName(dapp) {
                    let fontFileName = DappFonts.fontFileNameWithName(fontName)
                    
                    self.dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
                }
                
                self.dappStatementLabel.textColor = UIColor.whiteColor()
                
                if let colorName = DappHelper.getColorName(dapp) {
                    let color = DappColors.colorWithColorName(colorName)
                    
                    self.dappStatementLabel.backgroundColor = color
                }
                
                self.usernameLabel.text = nil
                self.userProfileImageView.image = nil
                
                if let userId = dapp["userid"] as? String {
                    let userQuery = PFUser.query()
                    
                    userQuery.whereKey("objectId", equalTo: userId)
                    
                    userQuery.findObjectsInBackgroundWithBlock({
                        (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error != nil {
                            print(error)
                            
                            return
                        }
                        
                        if let user = objects.first as? PFObject {
                            self.usernameLabel.text = user["name"] as? String
                            self.userProfileImageView.image = UIImage(data: user["image"] as! NSData)
                        } else {
                            self.usernameLabel.text = nil
                            self.userProfileImageView.image = nil
                        }
                    })
                }
            }
        } else {
            self.dappsSwipesCountLabel.text = nil
            
            self.dappStatementLabel.text = "No more DappSigns. Feel free to submit your own!"
            self.dappStatementLabel.textColor = UIColor.whiteColor()
            self.dappStatementLabel.backgroundColor = DappColors.colorWithColorName(.MidnightBlue)
            
            let fontFileName = DappFonts.fontFileNameWithName(.Exo)
            
            self.dappStatementLabel.font = UIFont(name: fontFileName, size: 25.0)
            
            self.usernameLabel.text = nil
            
            self.userProfileImageView.image = nil
        }
        
        self.scoreView.backgroundColor = self.dappStatementLabel.backgroundColor
        self.logoView.backgroundColor = self.dappStatementLabel.backgroundColor
        self.dappView.backgroundColor = self.dappStatementLabel.backgroundColor
    }
}
