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
    @IBOutlet weak var dappSignView:          UIView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton:   UIButton!
    
    internal var dapp: Dapp?
    internal var links: [Link]?
    internal var addDappVC: AddDappViewController?
    internal var addDappLinksVC: AddDappLinksVC?
    
    private var dappObj: PFObject?
    private var dappSignVC: DappSignVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareOnFacebookButton?.layer.cornerRadius = 8.0
        self.tweetThisCardButton?.layer.cornerRadius = 8.0
        
        self.dappSignView.alpha = 0
        
        AnimationHelper.showView(self.dappSignView, completion: nil)
        
        self.dappSignView.alpha = 1
        
        self.containerView.minTranslationX = 150.0
        self.containerView.delegate = self
        
        ViewHelper.disableViews([self.shareOnFacebookButton, self.tweetThisCardButton])
        
        if let dapp = self.dapp {
            self.submitDapp(dapp)
        }
        
        self.dappSignVC?.showDapp(self.dapp)
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
    
    @IBAction func showLinks(sender: AnyObject) {
        if let dapp = self.dappObj, embedDappVC = StoryboardHelper.instantiateEmbedDappVC() {
            self.addChildViewController(embedDappVC)
            
            let frame = embedDappVC.frameWithDappViewFrame(self.containerView.frame)
            
            embedDappVC.view.frame = frame
            
            self.view.addSubview(embedDappVC.view)
            
            embedDappVC.didMoveToParentViewController(self)
            embedDappVC.showURLAndIFrameCodeForDappWithID(dapp.objectId)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case DappSignVC.embedSegueID:
                self.dappSignVC = segue.destinationViewController as? DappSignVC
            case _:
                break
            }
        }
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
            
            ViewHelper.enableViews([self.shareOnFacebookButton, self.tweetThisCardButton])
            
            print("Dapp created with id: \(dappObj.objectId)")
            print(dappObj)
            
            DappArraysHelper.addDapp(dappObj, toArray: .Secondary, completion: {
                (error: NSError?) -> Void in
                if let error = error {
                    print(
                        "Failed to add dapp with ID \(dappObj.objectId) to Secondary array. " +
                        "Error: \(error.localizedDescription)"
                    )
                }
            })
            
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
}

extension FinalDappSubmitViewController: SwipeableViewDelegate {
    func willShow(swipeDirection: SwipeDirection) {
        self.dismissViewControllerAnimated(true, completion: {
            self.addDappLinksVC?.dismissViewControllerAnimated(true, completion: {
                self.addDappVC?.dismissViewControllerAnimated(true, completion: nil)
            })
        })
    }
    
    func didSwipe(swipeDirection: SwipeDirection) {}
}
