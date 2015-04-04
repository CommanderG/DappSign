//
//  FinalDappSubmitViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/4/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class FinalDappSubmitViewController: UIViewController {

    @IBOutlet weak var dappView: UIView!
    @IBOutlet weak var dappHeaderView: UIView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var dappFooterView: UIView!
    @IBOutlet weak var footerImage: UIImageView!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var dappScoreView: UIView!
    @IBOutlet weak var dappLogoView: UIView!
    @IBOutlet weak var scoreLabelText: UILabel!
    @IBOutlet weak var scoreLabelNum: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var dappTextView: UITextView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton: UIButton!
    
    //design
    var dappColors = DappColors()
    var dappFonts = DappFonts()

    
    
    //from previous VC
    var dappColorString:String!
    var dappFontString:String!
    var dappStatementString:String!
    var nameString:String!
    var dapp: PFObject!
    
    //animation stuff
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    var originalLocation: CGPoint!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareOnFacebookButton?.layer.cornerRadius = 8.0
        self.tweetThisCardButton?.layer.cornerRadius = 8.0
        
        var user = PFUser.currentUser()
        
        originalLocation = dappView.center
        animator = UIDynamicAnimator(referenceView: view)
        dappView.alpha = 0
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        dappView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.dappView.transform = CGAffineTransformConcat(scale, translate)
        }
        
        if self.dappColorString != nil {
            self.dappTextView.backgroundColor = dappColors.dappColorWheel[self.dappColorString]
        }
        
        self.dappTextView.text = dappStatementString
        
        if self.dappFontString != nil {
            self.dappTextView.font = dappFonts.dappFontBook[self.dappFontString]
        }
        
        self.dappTextView.textColor = UIColor.whiteColor()
        self.dappScoreView.backgroundColor = self.dappTextView.backgroundColor
        self.dappLogoView.backgroundColor = self.dappTextView.backgroundColor
        self.footerLabel.text = self.nameString
        
        if let imageData = user["image"] as NSData? {
            self.footerImage.image = UIImage(data: imageData)
        }
        
        self.dappView.alpha = 1

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func handleGesture(sender: AnyObject) {
        let location = sender.locationInView(view)
        let myView = dappView
        
        if sender.state == UIGestureRecognizerState.Began {
            animator.removeBehavior(snapBehavior)
            
            let centerOffset = UIOffsetMake(location.x - CGRectGetMidX(myView.bounds), location.y - CGRectGetMidY(myView.bounds));
            attachmentBehavior = UIAttachmentBehavior(item: myView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0
            
            animator.addBehavior(attachmentBehavior)
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            attachmentBehavior.anchorPoint = location
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            animator.removeBehavior(attachmentBehavior)
            
            snapBehavior = UISnapBehavior(item: myView, snapToPoint: originalLocation)
            animator.addBehavior(snapBehavior)
            
            let translation = sender.translationInView(view)
            if translation.x > 100 {
                animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [dappView])
                gravity.gravityDirection = CGVectorMake(10, -30)
                animator.addBehavior(gravity)
                
                delay(0.3) {
                    self.performSegueWithIdentifier("showHomeViewControllerAfterSubmit", sender: self)
                }
            }else if translation.x < -100 {
                animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [dappView])
                gravity.gravityDirection = CGVectorMake(-10, 30)
                animator.addBehavior(gravity)
                
                delay(0.3) {
                    self.performSegueWithIdentifier("showHomeViewControllerAfterSubmit", sender: self)
                }
            }
            
        }

        
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let currentDappCardAsImage = self.dappView.toImage()
        
        FacebookHelper.postImageToFacebook(currentDappCardAsImage,
            dapp: self.dapp!,
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
        if self.dapp == nil {
            return
        }
        
        let currentDappCardAsImage = self.dappView.toImage()
        
        TwitterHelper.tweetDapp(self.dapp!,
            image: currentDappCardAsImage,
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
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
