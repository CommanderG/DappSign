//
//  FinalDappSubmitViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/4/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class FinalDappSubmitViewController: UIViewController {
    @IBOutlet weak var containerView:         SwipeableView!
    @IBOutlet weak var dappSignView:          DappSignView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton:   UIButton!
    
    internal var dapp: Dapp?
    internal var links: [Link]?
    
    private var dappObj: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareOnFacebookButton?.layer.cornerRadius = 8.0
        self.tweetThisCardButton?.layer.cornerRadius = 8.0
        
        self.dappSignView.alpha = 0
        
        let scale = CGAffineTransformMakeScale(0.5, 0.5)
        let translate = CGAffineTransformMakeTranslation(0.0, -200.0)
        
        self.dappSignView.transform = CGAffineTransformConcat(scale, translate)
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            
            self.dappSignView.transform = CGAffineTransformConcat(scale, translate)
        }
        
        self.dappSignView.alpha = 1
        
        self.containerView.minTranslationX = 150.0
        self.containerView.delegate = self
        
        self.disableViews([self.shareOnFacebookButton, self.tweetThisCardButton])
        
        if let dapp = self.dapp {
            self.submitDapp(dapp)
        }
        
        self.dappSignView.showDapp(self.dapp)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let dappImage = self.dappSignView.toImage()
        
        if let dappObj = self.dappObj, dappImage = dappImage {
            FacebookHelper.postImageToFacebook(dappImage, dapp: dappObj, completion: {
                (success: Bool, error: NSError?) -> Void in
                if success {
                    self.showAlertViewWithOKButtonAndMessage(
                        "The card has been successfully posted."
                    )
                } else if let error = error {
                    self.showAlertViewWithOKButtonAndMessage(
                        "Failed to post the card. Error: \(error)"
                    )
                } else {
                    self.showAlertViewWithOKButtonAndMessage(
                        "Failed to post the card. Unknown error."
                    )
                }
            })
        }
    }
    
    @IBAction func tweetCurrentDappCard(sender: AnyObject) {
        let dappImage = self.dappSignView.toImage()
        
        if let dappObj = self.dappObj, dappImage = dappImage {
            TwitterHelper.tweetDapp(dappObj, image: dappImage, completion: {
                (success: Bool, error: NSError?) -> Void in
                    if success {
                        self.showAlertViewWithOKButtonAndMessage(
                            "The card has been successfully tweeted."
                        )
                    } else if let error = error {
                        self.showAlertViewWithOKButtonAndMessage(
                            "Failed to tweet the card. Error: \(error)"
                        )
                    } else {
                        self.showAlertViewWithOKButtonAndMessage(
                            "Failed to tweet the card. Unknown error."
                        )
                    }
            })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: -
    
    func submitDapp(dapp: Dapp) {
        let dappObj = PFObject(className: "Dapps")
        
        if let dappStatement = dapp.dappStatement {
            dappObj["dappStatement"] = dappStatement
        }
        
        if let lowercaseDappStatement = dapp.lowercaseDappStatement {
            dappObj["lowercaseDappStatement"] = lowercaseDappStatement
        }
        
        if let dappFont = dapp.dappFont {
            dappObj["dappFont"] = dappFont
        }
        
        if let dappBackgroundColor = dapp.dappBackgroundColor {
            dappObj["dappBackgroundColor"] = dappBackgroundColor
        }
        
        if let name = dapp.name {
            dappObj["name"] = name
        }
        
        if let userid = dapp.userid {
            dappObj["userid"] = userid
        }
        
        dappObj["dappScore"] = dapp.dappScore
        dappObj["isDeleted"] = dapp.isDeleted
        
        dappObj.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError!) -> Void in
            if !succeeded {
                print(error)
                
                return
            }
            
            self.dappObj = dappObj
            
            self.enableViews([self.shareOnFacebookButton, self.tweetThisCardButton])
            
            print("Dapp created with id: \(dappObj.objectId)")
            print(dappObj)
            
            Requests.uploadHashtags(dapp.hashtagNames, completion: {
                (hashtags: [PFObject]?, error: NSError!) -> Void in
                if error != nil {
                    print("Failed to upload hashtags \(dapp.hashtagNames). Error: \(error)")
                }
                
                if let hashtags = hashtags {
                    let hashtagsRelation = dappObj.relationForKey("hashtags")
                    
                    for hashtag in hashtags {
                        hashtagsRelation.addObject(hashtag)
                    }
                    
                    dappObj.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                        if success {
                            print("Successfully added hashtags to dapp.")
                        } else {
                            print("Failed to add hashtags to dapp. Error: \(error)")
                        }
                    })
                }
            })
            
            if let links = self.links {
                Requests.uploadLinks(links, completion: {
                    (linkObjs: [PFObject], error: NSError?) -> Void in
                    print("Finished uploading links.")
                    
                    if let error = error {
                        print("Links uploading error: \(error)")
                    }
                    
                    if linkObjs.count > 0 {
                        let linksRelation = dappObj.relationForKey("links")
                        
                        for linkObj in linkObjs {
                            linksRelation.addObject(linkObj)
                        }
                        
                        dappObj.saveInBackgroundWithBlock({
                            (success: Bool, error: NSError!) -> Void in
                            if success {
                                print("Successfully added links to dapp.")
                            } else {
                                print("Failed to add links to dapp. Error: \(error)")
                            }
                        })
                    }
                })
            }
            
            self.increamentDappScores(dappObj)
        })
    }
    
    private func increamentDappScores(dappObj: PFObject) {
        if let userID = dappObj["userid"] as? String {
            self.incrementDappScoreForUserWithID(userID)
        }
        
        let currentUserID = PFUser.currentUser().objectId
        
        self.incrementDappScoreForUserWithID(currentUserID)
    }
    
    private func incrementDappScoreForUserWithID(userID: String) {
        UserHelper.incrementDappScoreForUserWithID(userID, completion: {
            (success: Bool, errorMessage: String?) -> Void in
            if let errorMessage = errorMessage {
                print(errorMessage)
            }
        })
    }
    
    // MARK: - UI
    
    private func disableViews(views: [UIView]) {
        for view in views {
            view.userInteractionEnabled = false
            view.alpha = 0.5
        }
    }
    
    private func enableViews(views: [UIView]) {
        for view in views {
            view.userInteractionEnabled = true
            view.alpha = 1.0
        }
    }
}

extension FinalDappSubmitViewController: SwipeableViewDelegate {
    func willShow(swipeDirection: SwipeDirection) {
        self.performSegueWithIdentifier("showHomeViewControllerAfterSubmit", sender: self)
    }
    
    func didSwipe(swipeDirection: SwipeDirection) {}
}
