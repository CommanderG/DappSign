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
internal let dappsDappedRelationKey = "dappsDapped"

class HomeViewController: UIViewController, SwipeableViewDelegate {
    @IBOutlet weak var dappViewsContainerView: SwipeableView!
    @IBOutlet weak var dappSignView: DappSignView!
    @IBOutlet weak var dappMappView: DappMappView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var dappScoreLabel: UILabel!
    
    @IBOutlet var representativesImagesViews: [UIImageView]!
    @IBOutlet var plusOneLabels: [UILabel]!
    
    @IBOutlet var representativesPlusOneLabelsVerticalTopConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var dappsCountPlusOneLabelTopConstraint: NSLayoutConstraint!
    
    private var representativesImagesURLs: [NSURL] = []
    private var visibleDappView: UIView!
    private var lastDappedDapp: PFObject?
    private var animatingPlusOneLabels = false
    
    var dapps: [PFObject] = []
    var dappsDownloader: DappsDownloader?
    var dappFonts = DappFonts()
    var dappColors = DappColors()
    
    var timer: NSTimer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.dappTextView.TextAlignment
        
        self.dappScoreLabel.text = nil;
        
        self.dappViewsContainerView.hidden = true
        self.dappViewsContainerView.delegate = self
        self.dappViewsContainerView.minTranslationX = 150.0;
        
        self.showDappView(self.dappSignView)
        
        if PFUser.currentUser() == nil {
            self.profileButton.hidden = true
        }
        
        self.updateUserInformation()
        self.downloadDapps()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("handleDappSwipedNotification:"),
            name: DappSwipedNotification,
            object: nil
        )
        
        self.hideLabels(self.plusOneLabels)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0
        ,   target: self
        ,   selector: Selector("updateDappScore")
        ,   userInfo: nil
        ,   repeats: true
        )
        
        self.downloadRepresentativesImages()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.timer?.invalidate()
    }
    
    // MARK: - @IBActions
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let currentDappCardAsImage = self.dappViewsContainerView.toImage()
        let currentDapp = self.dapps.first
        
        if currentDapp == nil {
            return
        }
        
        if let currentDapp = self.dapps.first {
            FacebookHelper.postImageToFacebook(currentDappCardAsImage,
                dapp: currentDapp,
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
    }
    
    @IBAction func tweetCurrentDappCard(sender: AnyObject) {
        let currentDappCardAsImage = self.dappViewsContainerView.toImage()
        let currentDapp = self.dapps.first
        
        if currentDapp == nil {
            return
        }
        
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
    
    // MARK: - 
    
    private func sendRequestsForDapp(dapp: PFObject, dapped: Bool) {
        let currentUser = PFUser.currentUser()
        
        Requests.addDappToDappsSwipedArray(dapp, user: currentUser, completion: {
            (succeeded: Bool, error: NSError?) -> Void in
            if !succeeded {
                if let error = error {
                    println(error)
                }
                
                return
            }
            
            if !dapped {
                return
            }
            
            Requests.addDappToDappsDappedArray(dapp, user: currentUser, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        println("Failed to add dapp with ID \(dapp.objectId) to 'dappsDapped' array. Error = \(error.localizedDescription)")
                    } else {
                        println("Failed to add dapp with ID \(dapp.objectId) to 'dappsDapped' array. Unknown error.")
                    }
                }
            })
            
            Requests.incrementScoreOfTheDapp(dapp, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        println(error)
                    }
                    
                    return
                }
            })
            
            if let userId = dapp["userid"] as? String {
                Requests.incrementDappScoreForUserWithId(userId, completion: {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if !succeeded {
                        if let error = error {
                            println("Failed to update dappScore for user with id \(userId). Error: \(error.localizedDescription)")
                        } else {
                            println("Failed to update dappScore for user with id \(userId). Unknown error")
                        }
                    }
                })
            }
            
            let currentUserId = PFUser.currentUser().objectId
            
            Requests.incrementDappScoreForUserWithId(currentUserId, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        println(error.localizedDescription)
                    }
                }
            })
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
            user["image"] = data
            
            user.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    println("Successfully saved user's image.")
                } else {
                    println("Failed to save user's image.")
                    println("Errro: \(error)")
                }
            })
            
            FBRequestConnection.startForMeWithCompletionHandler({
                connection, result, error in
                if let resultDict = result as? NSDictionary {
                    let name = resultDict["name"] as! String
                    
                    user["name"] = name
                    user["lowercaseName"] = name.lowercaseString
                    
                    user.saveInBackgroundWithBlock({
                        (succeeded: Bool, error: NSError!) -> Void in
                        if succeeded {
                            println("Successfully saved user's name.")
                        } else {
                            println("Failed to save user's name.")
                            println("Errro: \(error)")
                        }
                    })
                }
            })
            
            user["dappScore"] = 0
            
            user.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    println("Successfully set user's dappScore to 0.")
                } else {
                    println("Failed to set user's dappScore to 0.")
                    println("Errro: \(error)")
                }
            })
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
        
        self.dappsDownloader?.downloadDappsNotSwipedByUser(user, completion: {
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
            let profileNC = segue.destinationViewController as! UINavigationController
            
            if let profileVC = profileNC.viewControllers.first as? ProfileViewController {
                profileVC.user = PFUser.currentUser()
            }
        }
    }
    
    // MARK: - Timer
    
    func updateDappScore() {
        let currentUser = PFUser.currentUser()
        
        Requests.downloadDappScoreForUserWithId(currentUser.objectId, completion: {
            (dappScore: Int?, error: NSError?) -> Void in
            if error != nil {
                println(error)
                
                self.dappScoreLabel.text = nil
                
                return
            }
            
            if let dappScore = dappScore {
                if dappScore == 1 {
                    self.dappScoreLabel.text = "1 Dapp"
                } else {
                    self.dappScoreLabel.text = "\(dappScore) Dapp"
                }
            }
        })
    }
    
    // MARK: -
    
    internal func handleDappSwipedNotification(notification: NSNotification) {
        if let dappId = notification.object as? String {
            if self.dapps.first?.objectId == dappId {
                self.dapps.removeAtIndex(0)
                
                self.initDappView()
            } else {
                self.dapps = self.dapps.filter({ $0.objectId != dappId })
            }
        }
    }
    
    private func initDappView() {
        if self.dappViewsContainerView.hidden {
            self.dappViewsContainerView.hidden = false
            
            self.dappViewsContainerView.show()
        }
        
        if (self.visibleDappView == self.dappSignView) {
            let dapp = dapps.first
            
            self.dappSignView.showDapp(dapp)
            
            if let dapp_ = dapp, userID = dapp_["userid"] as? String {
                Requests.userWithID(userID, completion: {
                    (user: PFUser?, error: NSError?) -> Void in
                    if let usr = user {
                        self.dappSignView.showUserInfo(usr)
                    } else if let err = error {
                        println("Failed to download information about user with ID \(userID). Error = \(error)")
                    } else {
                        println("Failed to download information about user with ID \(userID). Unknown error.")
                    }
                })
                
                Requests.addUserToUsersWhoSaw(dapp_, user: PFUser.currentUser(), completion: {
                    (succeeded: Bool, error: NSError!) -> Void in
                    if !succeeded {
                        if let err = error {
                            println("error = \(err)")
                        } else {
                            println("error = unknown")
                        }
                        
                        return
                    }
                })
            }
        } else if (self.visibleDappView == self.dappMappView) {
            let SVGMapURL = SVGMapGenerator.generate([:])
            
            // placeholders
            self.dappMappView.show(0, SVGMapURLPath: SVGMapURL, percents: 0)
            
            if let dapp = self.lastDappedDapp {
                Requests.percents(dapp, completion: {
                    (usersDapped: [PFUser:Bool]?, error: NSError?) -> Void in
                    if let usersDapped_ = usersDapped {
                        if usersDapped_.count >= 20 {
                            self.downloadDataForMapAndShowIt(usersDapped_, dapp: dapp)
                            
                            return
                        }
                        
                        var dappsCount = UInt(10 + arc4random_uniform(20))
                        var IDsFreqs = CongressionalDistrictsIDs.getRandomIDsFreqs(dappsCount)
                        let SVGMapURL = SVGMapGenerator.generate(IDsFreqs)
                        var percents = 0 as UInt
                        
                        if let
                            user = PFUser.currentUser(),
                            congrDistrID = user["congressionalDistrictID"] as? String {
                                var additionalFreq = UInt(1 + arc4random_uniform(4))
                                var dappTotalViews = 1 as UInt
                                var dappDapps = 1 as UInt
                                
                                if let freq = IDsFreqs[congrDistrID] as UInt? {
                                    IDsFreqs[congrDistrID] = freq + additionalFreq
                                    
                                    dappTotalViews = freq + additionalFreq
                                } else {
                                    IDsFreqs[congrDistrID] = additionalFreq
                                    
                                    dappTotalViews = additionalFreq
                                }
                                
                                dappDapps = UInt(arc4random_uniform(UInt32(dappTotalViews)))
                                
                                if dappDapps == 0 {
                                    dappDapps = 1
                                } else if dappDapps > dappTotalViews {
                                    dappDapps = dappTotalViews
                                }
                                
                                percents = UInt(roundf(Float(dappDapps) / Float(dappTotalViews) * 100))
                                dappsCount += additionalFreq
                        }
                        
                        self.dappMappView.show(dappsCount, SVGMapURLPath: SVGMapURL, percents: percents)
                    }
                })
            }
        }
    }
    
    private func downloadDataForMapAndShowIt(usersDapped: [PFObject:Bool], dapp: PFObject) {
        let users = usersDapped.keys.array
        let dapps = usersDapped.values.array
        
        CongressionalDistrictsIDs.getIDsFrequenciesForDapp(dapp, completion: {
            (IDsFreqs: IDsFrequencies?) -> Void in
            if let IDsFreqs_ = IDsFreqs {
                var dappScore = 0 as UInt
                
                if let dappScore_ = dapp["dappScore"] as? UInt {
                    dappScore = dappScore_
                }
                
                let SVGMapURL = SVGMapGenerator.generate(IDsFreqs_)
                var dappedCount = usersDapped.keys.array.filter({
                    let currentUser = PFUser.currentUser()
                    
                    if let
                        currentUserCongrDistrID = currentUser["congressionalDistrictID"] as? String,
                        userCongrDistrID = $0["congressionalDistrictID"] as? String {
                            if $0.objectId == currentUser.objectId {
                                // the back end hasn't been updated yet
                                return true
                            } else if currentUserCongrDistrID == userCongrDistrID {
                                if let dapped = usersDapped[$0] as Bool? {
                                    if dapped == true {
                                        return true
                                    }
                                }
                            }
                    }
                    
                    return false
                }).count
                
                var percents = 0 as UInt
                
                if dappedCount > 0 && dapps.count > 0 {
                    percents = UInt(roundf(Float(dappedCount) / Float(dapps.count) * 100))
                }
                
                self.dappMappView.show(dappScore, SVGMapURLPath: SVGMapURL, percents: percents)
            }
        })
    }
    
    func downloadRepresentativesImages() {
        func representativesImagesURLs(completion: (URLs: [NSURL]?) -> Void) {
            if self.representativesImagesURLs.count > 0 {
                completion(URLs: self.representativesImagesURLs)
                
                return
            }
            
            self.representativesImagesURLs = []
            
            let currentUser = PFUser.currentUser()
            
            Requests.downloadRepresentativesForUserWithID(currentUser.objectId, completion: {
                (representatives: [PFObject]?, error: NSError?) -> Void in
                if let representatives_ = representatives {
                    for representative in representatives_ {
                        if let
                            imgURLStr = representative["imgUrl"] as? String,
                            imgURL = NSURL(string: imgURLStr) {
                                self.representativesImagesURLs.append(imgURL)
                        }
                    }
                    
                    completion(URLs: self.representativesImagesURLs)
                } else {
                    if let err = error {
                        println("\(err)")
                    } else {
                        println("Unknown error.")
                    }
                    
                    completion(URLs: nil)
                }
            })
        }
        
        representativesImagesURLs { (URLs: [NSURL]?) -> Void in
            if let URLs_ = URLs {
                self.representativesImagesURLs = URLs_
                
                for index in 0 ... self.representativesImagesURLs.count {
                    if (index == self.representativesImagesURLs.count ||
                        index == self.representativesImagesViews.count) {
                            break
                    }
                    
                    let representativeImageView = self.representativesImagesViews[index]
                    
                    if representativeImageView.image != nil {
                        continue
                    }
                    
                    let URL = URLs_[index]
                    
                    Requests.downloadImageFromURL(URL, completion: {
                        (image: UIImage?, error: NSError?) -> Void in
                        if let img = image {
                            representativeImageView.image = img
                        } else if let err = error {
                            println("\(err)")
                        } else {
                            println("Unknown error.")
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - SwipeableViewDelegate
    
    func didSwipe(swipeDirection: SwipeDirection) {
        if (self.visibleDappView == self.dappSignView) {
            let dapped = (swipeDirection == SwipeDirection.LeftToRight)
            
            if let currentDapp = self.dapps.first {
                self.lastDappedDapp = currentDapp
                
                self.sendRequestsForDapp(currentDapp, dapped: dapped)
                
                if dapped {
                    self.showThenHidePlusOneLabels()
                }
            } else {
                self.lastDappedDapp = nil
            }
            
            if self.dapps.count > 0 {
                self.dapps.removeAtIndex(0)
            }
            
            if (dapped && self.dapps.count > 0) {
                self.showDappView(self.dappMappView)
            }
        } else {
            self.showDappView(self.dappSignView)
        }
        
        self.initDappView()
        
        if self.dapps.count == 0 {
            self.downloadDapps()
        }
    }
    
    // MARK: -
    
    private func showDappView(dappView: UIView) {
        if (dappView == self.dappSignView) {
            self.dappSignView.hidden = false
            self.dappMappView.hidden = true
            self.visibleDappView = dappView
        } else if (dappView == self.dappMappView) {
            self.dappSignView.hidden = true
            self.dappMappView.hidden = false
            self.visibleDappView = dappView
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func showThenHidePlusOneLabels() {
        if self.animatingPlusOneLabels {
            return
        }
        
        self.animatingPlusOneLabels = true
        
        var representativesPlusOneLabelsVerticalTopConstraintMax: CGFloat = 46.0
        var dappsCountPlusOneLabelTopConstraintMax: CGFloat = 34.0
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.showLabels(self.plusOneLabels)
            
            for topConstraint in self.representativesPlusOneLabelsVerticalTopConstraints {
                topConstraint.constant = representativesPlusOneLabelsVerticalTopConstraintMax - 15.0
            }
            
            self.dappsCountPlusOneLabelTopConstraint.constant = dappsCountPlusOneLabelTopConstraintMax - 15.0
            
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.hideLabels(self.plusOneLabels)
            }, completion: { (finished: Bool) -> Void in
                for topConstraint in self.representativesPlusOneLabelsVerticalTopConstraints {
                    topConstraint.constant = representativesPlusOneLabelsVerticalTopConstraintMax
                }
                
                self.dappsCountPlusOneLabelTopConstraint.constant = dappsCountPlusOneLabelTopConstraintMax
                
                self.view.layoutIfNeeded()
                
                self.animatingPlusOneLabels = false
            })
        })
    }
    
    private func showLabels(labels: [UILabel]) {
        for label in labels {
            label.alpha = 1.0
        }
    }
    
    private func hideLabels(labels: [UILabel]) {
        for label in labels {
            label.alpha = 0.0
        }
    }
}
