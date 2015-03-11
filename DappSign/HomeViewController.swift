//
//  HomeViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 2/28/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
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
    var dappData: NSMutableArray! = NSMutableArray()
    var count = 0 //index
    
    //dapp Colors and fonts
    var dappColors = DappColors()
    var dappFonts = DappFonts()
    
    //animator behavior variables
    var originalLocation: CGPoint!
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareOnFacebookButton?.layer.cornerRadius = 8.0
        self.tweetThisCardButton?.layer.cornerRadius = 8.0
        
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
                    self.user["name"] = result["name"]
                    self.user.save()
                    
                })
                
            })
            self.user["dappScore"] = 0
            self.user.save()
        }
        
        
        originalLocation = dappView.center
        animator = UIDynamicAnimator(referenceView: view)
        dappView.alpha = 0
        self.loadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(Bool())
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0, -200)
        dappView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.dappView.transform = CGAffineTransformConcat(scale, translate)
        }
        
        
        if count < dappData.count{
            self.dappTextView.text = dappData[count].objectForKey("dappStatement") as String!
            self.dappTextView.font = dappFonts.dappFontBook[dappData[count].objectForKey("dappFont") as String!]
            self.dappTextView.textColor = UIColor.whiteColor()
            self.dappTextView.backgroundColor = dappColors.dappColorWheel[dappData[count].objectForKey("dappBackgroundColor") as String!]
            self.scoreView.backgroundColor = self.dappTextView.backgroundColor
            self.logoView.backgroundColor = self.dappTextView.backgroundColor
        } else {
            self.dappTextView.text = "No more DappSigns. Feel free to submit your own!"
            self.dappTextView.font  = dappFonts.dappFontBook["exo"]!
            self.dappTextView.textColor = UIColor.whiteColor()
            self.dappTextView.backgroundColor = dappColors.dappColorWheel["midnightBlue"]
        }
        
        dappView.alpha = 1
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func refreshView() {
        count++
        
        animator.removeAllBehaviors()
        
        snapBehavior = UISnapBehavior(item:dappView, snapToPoint: view.center)
        attachmentBehavior.anchorPoint = view.center
        
        dappView.center = view.center ///uh......dunno
        
        viewDidAppear(true)
        
        
    }

    
    
    //load data from parse
    func loadData(){
        var findDappDeckData:PFQuery = PFQuery(className: "Dapps")
        
        findDappDeckData.findObjectsInBackgroundWithBlock { (objects:[AnyObject]!, error:NSError!) -> Void in
            
            if error == nil{
                for object in objects{
                    var dapp:PFObject = object as PFObject
                    self.dappData.addObject(dapp)
                    
                }
            }
        }
    }
    
    
    
    
    
    
    

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
            
            let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(myView.bounds), boxLocation.y - CGRectGetMidY(myView.bounds));
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
                    self.refreshView()
                }
            }else if translation.x < -100 {
                animator.removeAllBehaviors()
                
                var gravity = UIGravityBehavior(items: [dappView])
                gravity.gravityDirection = CGVectorMake(-10, 30)
                animator.addBehavior(gravity)
                
                delay(0.3) {
                    self.refreshView()
                }
            }
            
        }
        
    }
    
    
    @IBAction func profileButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("showProfileViewController", sender: self)
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
}
