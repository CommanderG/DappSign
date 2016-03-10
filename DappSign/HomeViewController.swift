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

enum DappCardType {
    case DappCardTypeSign;
    case DappCardTypeMapp
}

class HomeViewController: UIViewController, SwipeableViewDelegate {
    @IBOutlet weak var dappViewsContainerView: SwipeableView!
    @IBOutlet weak var dappSignView: DappSignView!
    @IBOutlet weak var dappMappView: DappMappView!
    @IBOutlet weak var shareOnFacebookButton: UIButton!
    @IBOutlet weak var tweetThisCardButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var dappScoreLabel: UILabel!
    @IBOutlet weak var linkView: LinkView!
    @IBOutlet weak var embedDappView: EmbedDappView!
    
    @IBOutlet var representativesImagesViews: [UIImageView]!
    
    @IBOutlet weak var plusOneDappsCountLabel: UILabel!
    @IBOutlet weak var plusOneFirstRepresentativeLabel: UILabel!
    @IBOutlet weak var plusOneSecondRepresentativeLabel: UILabel!
    @IBOutlet weak var plusOneThirdRepresentativeLabel: UILabel!
    
    @IBOutlet weak var plusOneDappsCountLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusOneFirstRepresentativeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusOneSecondRepresentativeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusOneThirdRepresentativeLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signedLabel: UILabel!
    
    @IBOutlet weak var signedLabelBottomConstraint: NSLayoutConstraint!
    
    private var representativesImagesURLs: [NSURL] = []
    private var visibleDappView: UIView!
    private var lastDappedDapp: PFObject?
    private var animatingPlusOneLabels = false
    private var dappLinksVC: DappLinksVC?
    private var links: [Link] = []
    
    private let embedDappLinksVCSegueID = "embedDappLinksVCSegue"
    private let flipDuration = 0.5
    
    var dapps: [PFObject] = []
    var dappsDownloader: DappsDownloader?
    var dappFonts = DappFonts()
    var dappColors = DappColors()
    
    var timer: NSTimer? = nil
    
    private var currentDappCardType: DappCardType = .DappCardTypeSign
    
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
        
        let labels = [
            self.plusOneDappsCountLabel,
            self.plusOneFirstRepresentativeLabel,
            self.plusOneSecondRepresentativeLabel,
            self.plusOneThirdRepresentativeLabel,
            self.signedLabel
        ]
        
        for label in labels {
            self.hideLabel(label)
        }
        
        self.linkView.delegate = self
        self.linkView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target:   self,
            selector: Selector("updateDappScore"),
            userInfo: nil,
            repeats:  true
        )
        
        self.downloadRepresentativesImages()
        
        self.hideSignedLabel()
        
        let topConstraints = [
            self.plusOneDappsCountLabelTopConstraint,
            self.plusOneFirstRepresentativeLabelTopConstraint,
            self.plusOneSecondRepresentativeLabelTopConstraint,
            self.plusOneThirdRepresentativeLabelTopConstraint
        ]
        
        for topConstraint in topConstraints {
            if let constant = self.constantMaxForConstraint(topConstraint) {
                topConstraint.constant = constant
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.timer?.invalidate()
    }
    
    // MARK: - @IBActions
    
    @IBAction func handleDappSignTapGesture(tapGR: UITapGestureRecognizer) {
        if let dappLinksVCView = self.dappLinksVC?.view {
            self.flipWithDuration(self.flipDuration,
                view1: self.dappViewsContainerView,
                view2: dappLinksVCView
            )
        }
        
        if let dapp = self.dapps.first {
            Requests.downloadLinksForDapp(dapp, completion: {
                (linkObjs: [PFObject]?, error: NSError?) -> Void in
                self.links.removeAll()
                self.dappLinksVC?.initWithMode(.Read, andLinks: self.links)
                
                if let linkObjs = linkObjs {
                    self.links = self.linksWithLinkObjs(linkObjs)
                    
                    self.dappLinksVC?.initWithMode(.Read, andLinks: self.links)
                } else if let error = error {
                    print("Error downloading links for dapp with ID \(dapp.objectId): \(error)")
                }
            })
        }
    }
    
    @IBAction func handleDappLinksTapGesture(tapGR: UITapGestureRecognizer) {
        if let dappLinksVCView = self.dappLinksVC?.view {
            self.flipWithDuration(self.flipDuration,
                view1: self.dappViewsContainerView,
                view2: dappLinksVCView
            )
        }
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        if let
            currentDappCardAsImage = self.dappViewsContainerView.toImage(),
            currentDapp = self.dapps.first {
                FacebookHelper.postImageToFacebook(currentDappCardAsImage,
                    dapp: currentDapp,
                    completion: {
                        (success: Bool, error: NSError?) -> Void in
                        if success {
                            self.showAlertViewWithOKButtonAndMessage(
                                "The card has been successfully posted."
                            )
                        } else {
                            if let error = error {
                                self.showAlertViewWithOKButtonAndMessage(
                                    "Failed to post the card. Error: \(error)"
                                )
                            } else {
                                self.showAlertViewWithOKButtonAndMessage(
                                    "Failed to post the card. Unknown error."
                                )
                            }
                        }
                })
        }
    }
    
    @IBAction func tweetCurrentDappCard(sender: AnyObject) {
        if let
            currentDappCardAsImage = self.dappViewsContainerView.toImage(),
            currentDapp = self.dapps.first {
                TwitterHelper.tweetDapp(currentDapp,
                    image: currentDappCardAsImage,
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
    
    @IBAction func showLinkView(sender: AnyObject) {
        if let dapp = self.dapps.first {
            if self.embedDappView.hidden {
                self.embedDappView.hidden = false
                
                self.embedDappView.initURLAndEmbedCodeForDappWithID(dapp.objectId)
            }
        }
    }
    
    // MARK: -
    
    private func flipWithDuration(duration: NSTimeInterval, view1: UIView, view2: UIView) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationTransition(.FlipFromLeft, forView: view1, cache: true)
        UIView.commitAnimations()
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationTransition(.FlipFromLeft, forView: view2, cache: true)
        
        view1.hidden = !view1.hidden
        view2.hidden = !view2.hidden
        
        UIView.commitAnimations()
    }
    
    private func sendRequestsForDapp(dapp: PFObject, dapped: Bool) {
        let currentUser = PFUser.currentUser()
        
        Requests.addDappToDappsSwipedArray(dapp, user: currentUser, completion: {
            (succeeded: Bool, error: NSError?) -> Void in
            if !succeeded {
                if let error = error {
                    print(error)
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
                        print(
                            "Failed to add dapp with ID \(dapp.objectId) to 'dappsDapped' array. " +
                            "Error = \(error.localizedDescription)"
                        )
                    } else {
                        print(
                            "Failed to add dapp with ID \(dapp.objectId) to 'dappsDapped' array. " +
                            "Unknown error."
                        )
                    }
                }
            })
            
            Requests.incrementScoreOfTheDapp(dapp, completion: {
                (succeeded: Bool, error: NSError?) -> Void in
                if !succeeded {
                    if let error = error {
                        print(error)
                    }
                    
                    return
                }
            })
            
            self.incrementDappScores(dapp)
            
            DailyDappHelper.addDapp(dapp, completion: {
                (error: NSError?) -> Void in
                let dappID = dapp.objectId
                let dappStatement = dapp["dappStatement"] as? String ?? ""
                
                if let error = error {
                    print(
                        "Failed to add dapp with ID \"\(dappID)\" " +
                        "and statement \"\(dappStatement)\" to DailyDapp. " +
                        "Error: \(error.localizedDescription)"
                    )
                } else {
                    print(
                        "Successfully added dapp with ID \"\(dappID)\" " +
                        "and statement \"\(dappStatement)\" to DailyDapp."
                    )
                }
            })
        })
    }
    
    private func incrementDappScores(dapp: PFObject) {
        if let userID = dapp["userid"] as? String {
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
    
    private func linksWithLinkObjs(linkObjs: [PFObject]) -> [Link] {
        let links = linkObjs.map({
            linkObj -> Link in
            let link = Link(linkObj: linkObj)
            
            return link
        })
        
        return links
    }
    
    // MARK: - Requests
    
    private func updateUserInformation() {
        let user = PFUser.currentUser()
        
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
            (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            user["image"] = data
            
            user.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    print("Successfully saved user's image.")
                } else {
                    print("Failed to save user's image.")
                    print("Errro: \(error)")
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
                            print("Successfully saved user's name.")
                        } else {
                            print("Failed to save user's name.")
                            print("Errro: \(error)")
                        }
                    })
                }
            })
            
            user["dappScore"] = 0
            
            user.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    print("Successfully set user's dappScore to 0.")
                } else {
                    print("Failed to set user's dappScore to 0.")
                    print("Errro: \(error)")
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
                    print(error)
                    
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
                print(error)
                
                self.initDappView()
                
                return
            }
            
            if dapps.count > 0 {
                var shouldShowCurrentDapp = false;
                
                if self.dapps.count == 0 {
                    shouldShowCurrentDapp = true
                }
                
                DappsHelper.sortSecondaryDapps(dapps, completion: {
                    (sortedSecondaryDapps: [PFObject]) -> Void in
                    self.dapps += sortedSecondaryDapps
                    
                    if shouldShowCurrentDapp {
                        self.initDappView()
                    }
                })
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
        } else if segue.identifier == "embedDappLinksVCSegue" {
            self.dappLinksVC = segue.destinationViewController as? DappLinksVC
            self.dappLinksVC?.view.hidden = true
            self.dappLinksVC?.delegate = self
            
            self.dappLinksVC?.initWithMode(.Read, andLinks: self.links)
            
            let tapGR = UITapGestureRecognizer(
                target: self,
                action: Selector("handleDappLinksTapGesture:")
            )
            
            self.dappLinksVC?.view.addGestureRecognizer(tapGR)
        }
    }
    
    // MARK: - Timer
    
    func updateDappScore() {
        let currentUserID = PFUser.currentUser().objectId
        
        Requests.userWithID(currentUserID) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user, dappScore = user["dappScore"] as? Int {
                self.dappScoreLabel.text = "\(dappScore) Dapp"
            } else {
                self.dappScoreLabel.text = "- Dapps"
            }
        }
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
            
            if let
                dapp = dapp,
                dappBgColoName = dapp["dappBackgroundColor"] as? String,
                colorName = ColorName(rawValue: dappBgColoName) {
                    self.dappLinksVC?.view.backgroundColor =
                        DappColors.colorWithColorName(colorName)
            }
            
            if let dapp_ = dapp, userID = dapp_["userid"] as? String {
                Requests.userWithID(userID, completion: { (user: PFUser?, error: NSError?) -> Void in
                    if let usr = user {
                        self.dappSignView.showUserInfo(usr)
                    } else if let err = error {
                        print("Failed to download information about user with ID \(userID). Error = \(err)")
                    } else {
                        print("Failed to download information about user with ID \(userID). Unknown error.")
                    }
                })
                
                Requests.addUserToUsersWhoSaw(dapp_, user: PFUser.currentUser(), completion: {
                    (succeeded: Bool, error: NSError!) -> Void in
                    if !succeeded {
                        if let err = error {
                            print("error = \(err)")
                        } else {
                            print("error = unknown")
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
                                let additionalFreq = UInt(1 + arc4random_uniform(4))
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
                                
                                percents = UInt(
                                    roundf(Float(dappDapps) /
                                    Float(dappTotalViews) * 100)
                                )
                                
                                dappsCount += additionalFreq
                        }
                        
                        self.dappMappView.show(dappsCount,
                            SVGMapURLPath: SVGMapURL,
                            percents: percents
                        )
                    }
                })
            }
        }
    }
    
    private func downloadDataForMapAndShowIt(usersDapped: [PFObject:Bool], dapp: PFObject) {
        let dapps = Array(usersDapped.values)
        
        CongressionalDistrictsIDs.getIDsFrequenciesForDapp(dapp, completion: {
            (IDsFreqs: IDsFrequencies?) -> Void in
            if let IDsFreqs_ = IDsFreqs {
                var dappScore = 0 as UInt
                
                if let dappScore_ = dapp["dappScore"] as? UInt {
                    dappScore = dappScore_
                }
                
                let SVGMapURL = SVGMapGenerator.generate(IDsFreqs_)
                let dappedCount = Array(usersDapped.keys).filter({
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
                        print("\(err)")
                    } else {
                        print("Unknown error.")
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
                            print("\(err)")
                        } else {
                            print("Unknown error.")
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - SwipeableViewDelegate
    
    func willShow(swipeDirection: SwipeDirection) {
        switch self.currentDappCardType {
        case .DappCardTypeSign:
            if self.visibleDappView != self.dappSignView {
                self.showDappView(self.dappSignView)
            }
            
            break
        case .DappCardTypeMapp:
            if self.visibleDappView != self.dappMappView {
                self.showDappView(self.dappMappView)
            }
            
            break
        }
        
        self.initDappView()
    }
    
    func didSwipe(swipeDirection: SwipeDirection) {
        if (self.visibleDappView == self.dappSignView) {
            let dapped = (swipeDirection == SwipeDirection.LeftToRight)
            
            if let currentDapp = self.dapps.first {
                self.lastDappedDapp = currentDapp
                
                self.sendRequestsForDapp(currentDapp, dapped: dapped)
                
                if dapped {
                    UIView.animateWithDuration(0.4,
                        animations: {
                            self.dappViewsContainerView.alpha = 0.0
                        }, completion: { (finished: Bool) -> Void in
                            self.performDappAnimationsWithCompletion({
                                self.dappViewsContainerView.alpha = 1.0
                                self.currentDappCardType = DappCardType.DappCardTypeMapp
                                
                                self.dappViewsContainerView.show()
                            })
                        }
                    )
                } else {
                    self.currentDappCardType = DappCardType.DappCardTypeSign
                }
            } else {
                self.lastDappedDapp = nil
            }
            
            if self.dapps.count > 0 {
                self.dapps.removeAtIndex(0)
            }
            
            if self.dapps.count == 0 {
                self.downloadDapps()
            }
        } else {
            self.currentDappCardType = DappCardType.DappCardTypeSign
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
    
    private func constantMaxForConstraint(constraint: NSLayoutConstraint) -> CGFloat? {
        let topConstraintConstMax = [
            self.plusOneDappsCountLabelTopConstraint:           CGFloat(-16.0 + 80.0),
            self.plusOneFirstRepresentativeLabelTopConstraint:  CGFloat(30.0 + 80.0),
            self.plusOneSecondRepresentativeLabelTopConstraint: CGFloat(30.0 + 80.0),
            self.plusOneThirdRepresentativeLabelTopConstraint:  CGFloat(30.0 + 80.0)
        ]
        
        return topConstraintConstMax[constraint]
    }
    
    private func hideSignedLabel() {
        let signedLabelHeight = CGRectGetHeight(self.signedLabel.frame)
        
        self.signedLabelBottomConstraint.constant = -signedLabelHeight
    }
    
    private func performDappAnimationsWithCompletion(completion: () -> ()) {
        if self.animatingPlusOneLabels {
            return
        }
        
        self.animatingPlusOneLabels = true
        
        let plusOneLabels = [
            self.plusOneDappsCountLabel,
            self.plusOneFirstRepresentativeLabel,
            self.plusOneSecondRepresentativeLabel,
            self.plusOneThirdRepresentativeLabel
        ]
        
        let labelTopConstraint = [
            self.plusOneDappsCountLabel:           plusOneDappsCountLabelTopConstraint,
            self.plusOneFirstRepresentativeLabel:  plusOneFirstRepresentativeLabelTopConstraint,
            self.plusOneSecondRepresentativeLabel: plusOneSecondRepresentativeLabelTopConstraint,
            self.plusOneThirdRepresentativeLabel:  plusOneThirdRepresentativeLabelTopConstraint
        ]
        
        let topConstraintMin = [
            self.plusOneDappsCountLabelTopConstraint:           CGFloat(-16.0),
            self.plusOneFirstRepresentativeLabelTopConstraint:  CGFloat(30.0),
            self.plusOneSecondRepresentativeLabelTopConstraint: CGFloat(30.0),
            self.plusOneThirdRepresentativeLabelTopConstraint:  CGFloat(30.0)
        ]
        
        let plusOneLabelsMoveUpAnimationDuration = 0.6
        let plusOneLabelsDissapearanceAnimationDuration = 0.3
        
        for var index = 0; index < plusOneLabels.count; ++index {
            let animationDelay =
            (plusOneLabelsMoveUpAnimationDuration / Double(plusOneLabels.count)) * Double(index)
            
            if let label    = plusOneLabels[index],
                constraint  = labelTopConstraint[label],
                constantMin = topConstraintMin[constraint],
                constantMax = constantMaxForConstraint(constraint) {
                    UIView.animateWithDuration(plusOneLabelsMoveUpAnimationDuration,
                        delay: animationDelay,
                        usingSpringWithDamping: 0.4,
                        initialSpringVelocity: 0.0,
                        options: .CurveLinear,
                        animations: { () -> Void in
                            self.showLabel(label)
                            
                            constraint.constant = CGFloat(constantMin)
                            
                            self.view.layoutIfNeeded()
                        }, completion: { (finished: Bool) -> Void in
                            UIView.animateWithDuration(plusOneLabelsDissapearanceAnimationDuration,
                                animations: { () -> Void in
                                    self.hideLabel(label)
                                }, completion: { (finished: Bool) -> Void in
                                    constraint.constant = CGFloat(constantMax)
                                }
                            )
                        }
                    )
            }
        }
        
        let bottomConst =
            CGRectGetHeight(self.view.frame) / 2 - CGRectGetHeight(self.signedLabel.frame) / 2
        
        self.showLabel(self.signedLabel)
        
        let lastPlusOneAnimationsFinishedDelay =
            (plusOneLabelsMoveUpAnimationDuration / Double(plusOneLabels.count)) *
            Double(plusOneLabels.count - 1) +
            plusOneLabelsMoveUpAnimationDuration +
            plusOneLabelsDissapearanceAnimationDuration
        
        UIView.animateWithDuration(0.5,
            delay: lastPlusOneAnimationsFinishedDelay,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.0,
            options: .CurveLinear,
            animations: { () -> Void in
                self.signedLabelBottomConstraint.constant = bottomConst
                self.signedLabel.transform = CGAffineTransformMakeScale(1.5, 1.5)
                
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(0.3,
                    delay: 0.15,
                    options: .CurveLinear,
                    animations: { () -> Void in
                        self.hideLabel(self.signedLabel)
                    }, completion: { (finished: Bool) -> Void in
                        self.hideSignedLabel()
                        
                        self.signedLabel.transform = CGAffineTransformIdentity;
                        self.animatingPlusOneLabels = false
                        
                        completion()
                    }
                )
            }
        )
    }
    
    private func showLabel(label: UILabel) {
        label.alpha = 1.0
    }
    
    private func hideLabel(label: UILabel) {
        label.alpha = 0.0
    }
}

extension HomeViewController: DappLinksVCDelegate {
    func addLink(link: Link, completion: (success: Bool, error: NSError?) -> Void) {}
    
    func deleteLink(linkToDelete: Link, completion: (success: Bool, error: NSError?) -> Void) {}
    
    func openLinkURL(linkURL: NSURL) {
        self.linkView.hidden = false
        
        self.linkView.openURL(linkURL)
    }
}

extension HomeViewController: LinkViewDelegate {
    func closeLinkView() {
        self.linkView.hidden = true
    }
}
