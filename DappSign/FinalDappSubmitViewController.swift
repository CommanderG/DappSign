//
//  FinalDappSubmitViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/4/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class FinalDappSubmitViewController: UIViewController, SwipeableViewDelegate {
    @IBOutlet weak var containerView: SwipeableView!
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
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var dappStatementLabel: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareOnFacebookButton?.layer.cornerRadius = 8.0
        self.tweetThisCardButton?.layer.cornerRadius = 8.0
        
        var user = PFUser.currentUser()
        
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
            self.dappStatementLabel.backgroundColor = dappColors.dappColorWheel[self.dappColorString]
        }
        
        self.dappStatementLabel.text = dappStatementString
        
        if self.dappFontString != nil {
            self.dappStatementLabel.font = dappFonts.dappFontBook[self.dappFontString]
        }
        
        self.dappStatementLabel.textColor = UIColor.whiteColor()
        self.dappScoreView.backgroundColor = self.dappStatementLabel.backgroundColor
        self.dappLogoView.backgroundColor = self.dappStatementLabel.backgroundColor
        self.dappView.backgroundColor = self.dappStatementLabel.backgroundColor
        self.footerLabel.text = self.nameString
        
        if let imageData = user["image"] as? NSData {
            self.footerImage.image = UIImage(data: imageData)
        }
        
        self.dappView.alpha = 1
        
        self.containerView.minTranslationX = 150.0
        self.containerView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

extension FinalDappSubmitViewController: SwipeableViewDelegate {
    func didSwipe(swipeDirection: SwipeDirection) {
        self.performSegueWithIdentifier("showHomeViewControllerAfterSubmit", sender: self)
    }
}
