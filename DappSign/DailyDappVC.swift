//
//  HomeViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 2/28/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

internal let DappSwipedNotification = "dappSwipedNotification"

enum DappCardType {
    case DappCardTypeSign;
    case DappCardTypeMapp
}

class DailyDappVC: UIViewController, SwipeableViewDelegate {
    @IBOutlet weak var dappViewsContainerView:      SwipeableView!
    @IBOutlet weak var dappSignView:                UIView!
    @IBOutlet weak var dappMappView:                UIView!
    @IBOutlet weak var shareOnFacebookButton:       UIButton!
    @IBOutlet weak var tweetThisCardButton:         UIButton!
    @IBOutlet weak var profileButton:               UIButton!
    @IBOutlet weak var composeButton:               UIButton!
    @IBOutlet weak var searchButton:                UIButton!
    @IBOutlet weak var dappScoreLabel:              UILabel!
    @IBOutlet weak var plusOneDappsCountLabel:      UILabel!
    @IBOutlet weak var plusOneRepresentativeLabel:  UILabel!
    @IBOutlet weak var signedLabel:                 UILabel!
    @IBOutlet weak var hashtagsLabel:               UILabel!
    @IBOutlet weak var dailyDappTimeLeftLabel:      UILabel!
    
    @IBOutlet weak var plusOneDappsCountLabelTopConstraint:     NSLayoutConstraint!
    @IBOutlet weak var plusOneRepresentativeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signedLabelBottomConstraint:             NSLayoutConstraint!
    
    internal var transitionDelegate: TransitionDelegate? = nil
    
    private var embedDappVC: EmbedDappVC? = nil
    private var dappSignVC: DappSignVC? = nil
    private var dappMappVC: DappMappVC? = nil
    private var visibleDappView: UIView!
    private var lastDappedDapp: PFObject?
    private var dappBackSideLinksVC: DappBackSideLinksVC?
    private var dailyDappTimeLeftLabelUpdateTimer: NSTimer? = nil
    private var dailyDappTimeLeftUpdateTimer: NSTimer? = nil
    private var dailyDappTimeLeft: (Int, Int)? = nil
    private var animatingPlusOneLabels = false
    private var dapps: [PFObject] = []
    private var lastIntroductoryDappID: String? = nil
    private var timer: NSTimer? = nil
    private var currentDappCardType: DappCardType = .DappCardTypeSign
    
    private let flipDuration = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttons = [
            self.profileButton,
            self.composeButton,
            self.searchButton
        ]
        
        for button in buttons {
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 2.0
            button.layer.cornerRadius = 6.0
        }
        
        self.searchButton.hidden = true
        
        self.dappScoreLabel.text = nil
        
        self.dappViewsContainerView.hidden = true
        self.dappViewsContainerView.delegate = self
        self.dappViewsContainerView.minTranslationX = 150.0;
        
        self.showDappView(self.dappSignView)
        
        if PFUser.currentUser() == nil {
            self.profileButton.hidden = true
        }
        
        self.updateUserInformation()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("handleDappSwipedNotification:"),
            name: DappSwipedNotification,
            object: nil
        )
        
        let labels = [
            self.plusOneDappsCountLabel,
            self.plusOneRepresentativeLabel,
            self.signedLabel
        ]
        
        for label in labels {
            self.hideLabel(label)
        }
        
        self.hashtagsLabel.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userIsNew = LocalStorage.userIsNew()
        
        if !userIsNew {
            self.initTimers()
        }
        
        self.updateDailyDappTimeLeftLabel()
        self.updateDailyDappTimeLeft()
        self.downloadDapps()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.dailyDappTimeLeftLabelUpdateTimer?.invalidate()
        self.dailyDappTimeLeftUpdateTimer?.invalidate()
        
        self.dailyDappTimeLeft = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target:   self,
            selector: Selector("updateDappScore"),
            userInfo: nil,
            repeats:  true
        )
        
        self.hideSignedLabel()
        
        let topConstraints = [
            self.plusOneDappsCountLabelTopConstraint,
            self.plusOneRepresentativeLabelTopConstraint
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
    
    // MARK: -
    
    private func initTimers() {
        self.dailyDappTimeLeftLabelUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target:   self,
            selector: "updateDailyDappTimeLeftLabel",
            userInfo: nil,
            repeats:  true
        )
        self.dailyDappTimeLeftUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5,
            target:   self,
            selector: "updateDailyDappTimeLeft",
            userInfo: nil,
            repeats:  true
        )
    }
    
    // MARK: - @IBActions
    
    @IBAction func handleDappSignTapGesture(tapGR: UITapGestureRecognizer) {
        if let dappBackSideLinksVC = self.dappBackSideLinksVC, dapp = self.dapps.first {
            self.flipWithDuration(self.flipDuration,
                view1: self.dappViewsContainerView,
                view2: dappBackSideLinksVC.view
            )
            
            dappBackSideLinksVC.showLinksForDapp(dapp)
        }
    }
    
    @IBAction func handleDappLinksTapGesture(tapGR: UITapGestureRecognizer) {
        if let dappBackSideLinksView = self.dappBackSideLinksVC?.view {
            self.flipWithDuration(self.flipDuration,
                view1: self.dappViewsContainerView,
                view2: dappBackSideLinksView
            )
        }
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        let dappImage = self.dappViewsContainerView.toImage()
        
        if let dappImage = dappImage, currentDapp = self.dapps.first {
            FacebookHelper.postImageToFacebook(dappImage, dapp: currentDapp, completion: {
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
        let dappImage = self.dappViewsContainerView.toImage()
        
        if let dappImage = dappImage, currentDapp = self.dapps.first {
            TwitterHelper.tweetDapp(currentDapp, image: dappImage, completion: {
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
    
    @IBAction func showLinkView(sender: AnyObject) {
        if let dapp = self.dapps.first, embedDappVC = StoryboardHelper.instantiateEmbedDappVC() {
            self.addChildViewController(embedDappVC)
            
            let frame = embedDappVC.frameWithDappViewFrame(self.dappViewsContainerView.frame)
            
            embedDappVC.view.frame = frame
            
            self.view.addSubview(embedDappVC.view)
            
            embedDappVC.didMoveToParentViewController(self)
            embedDappVC.showURLAndIFrameCodeForDappWithID(dapp.objectId)
            embedDappVC.show()
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
        let URLString = "https://graph.facebook.com/me/picture?" +
                        "type=large"                             +
                        "&return_ssl_resources+1"                +
                        "&access_token=\(accessToken)"
        
        let url = NSURL(string: URLString)
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
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case "showProfile":
                let profileNC = segue.destinationViewController as? UINavigationController
                let profileVC = profileNC?.viewControllers.first as? ProfileViewController
                
                profileVC?.user = PFUser.currentUser()
            case "embedDappBackSideLinksVC":
                self.dappBackSideLinksVC = segue.destinationViewController as? DappBackSideLinksVC
                
                self.dappBackSideLinksVC?.view.hidden = true
                self.dappBackSideLinksVC?.delegate = self
                
                let tapGR = UITapGestureRecognizer(
                    target: self,
                    action: Selector("handleDappLinksTapGesture:")
                )
                
                self.dappBackSideLinksVC?.view.addGestureRecognizer(tapGR)
            case "embedEmbedDappVCSegue":
                self.embedDappVC = segue.destinationViewController as? EmbedDappVC
                
                self.embedDappVC?.view.hidden = true
            case DappSignVC.embedSegueID:
                self.dappSignVC = segue.destinationViewController as? DappSignVC
            case "embedDappMappVC":
                self.dappMappVC = segue.destinationViewController as? DappMappVC
            case _:
                break
            }
        }
    }
    
    // MARK: - Timer
    
    func updateDappScore() {
        let currentUserID = PFUser.currentUser().objectId
        
        Requests.userWithID(currentUserID) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user, dappScore = user["dappScore"] as? Int {
                self.dappScoreLabel.text = "\(dappScore)"
            } else {
                self.dappScoreLabel.text = "-"
            }
        }
    }
    
    // MARK: - timer functions
    
    internal func updateDailyDappTimeLeftLabel() {
        struct show {
            static var colon = false
        }
        
        show.colon = !show.colon
        
        if let (minutes, seconds) = self.dailyDappTimeLeft {
            let minutesString = self.stringForDoubleDigitInt(minutes)
            let secondsString = self.stringForDoubleDigitInt(seconds)
            
            if show.colon {
                self.dailyDappTimeLeftLabel.text = "\(minutesString):\(secondsString)"
            } else {
                self.dailyDappTimeLeftLabel.text = "\(minutesString) \(secondsString)"
            }
            
            if minutes <= 0 && seconds <= 0 {
                self.transitionDelegate?.transitionFromViewController(self)
            }
        } else {
            if show.colon {
                self.dailyDappTimeLeftLabel.text = "--:--"
            } else {
                self.dailyDappTimeLeftLabel.text = "-- --"
            }
        }
    }
    
    internal func updateDailyDappTimeLeft() {
        if let timeInterval = DailyDappDatesHelper.timeIntervalBeforeCurrentDailyDappEnd() {
            self.dailyDappTimeLeft = DateHelper.minutesAndSecondsInTimeInterval(timeInterval)
        } else {
            self.dailyDappTimeLeft = nil
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
        
        if let dapp = self.dapps.first {
            DappsHelper.downloadHashtagsForDapp(dapp, completion: {
                (hashtags: [PFObject]?, error: NSError?) -> Void in
                if let hashtags = hashtags {
                    let hashtagNames = HashtagHelper.hashtagNamesStringWithHashtags(hashtags)
                    
                    self.hashtagsLabel.text = hashtagNames
                }
            })
        } else {
            self.hashtagsLabel.text = ""
        }
        
        if (self.visibleDappView == self.dappSignView) {
            let dapp = self.dapps.first
            
            self.dappSignVC?.showDappObject(dapp)
            
            if let dapp = dapp {
                Requests.addUserToUsersWhoSaw(dapp, user: PFUser.currentUser(), completion: {
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
            if let dapp = self.dapps.first {
                self.dappMappVC?.showInformationAboutDapp(dapp)
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
                    
                    self.initTimersAfterCheckingLastIntroductoryDappID()
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
            
            self.initTimersAfterCheckingLastIntroductoryDappID()
        }
    }
    
    // MARK: -
    
    private func initTimersAfterCheckingLastIntroductoryDappID() {
        if let lastIntroductoryDappID = self.lastIntroductoryDappID {
            if self.lastDappedDapp?.objectId == lastIntroductoryDappID || self.dapps.count == 0 {
                self.initTimers()
                
                self.lastIntroductoryDappID = nil
            }
        }
    }
    
    private func downloadDapps() {
        self.dapps = []
        
        DailyDappHelper.downloadDapps {
            (dapps: [PFObject], lastIntroductoryDappID: String?) -> Void in
            self.dapps = dapps
            self.lastIntroductoryDappID = lastIntroductoryDappID
            
            self.initDappView()
            
            let userIsNew = LocalStorage.userIsNew()
            
            if userIsNew && lastIntroductoryDappID == nil {
                self.initTimers()
            }
            
            LocalStorage.saveUserIsNew(false)
        }
    }
    
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
            self.plusOneDappsCountLabelTopConstraint:     CGFloat(-16.0 + 80.0),
            self.plusOneRepresentativeLabelTopConstraint: CGFloat(30.0 + 80.0)
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
            self.plusOneRepresentativeLabel
        ]
        
        let labelTopConstraint = [
            self.plusOneDappsCountLabel:     plusOneDappsCountLabelTopConstraint,
            self.plusOneRepresentativeLabel: plusOneRepresentativeLabelTopConstraint
        ]
        
        let topConstraintMin = [
            self.plusOneDappsCountLabelTopConstraint:     CGFloat(-16.0),
            self.plusOneRepresentativeLabelTopConstraint: CGFloat(30.0)
        ]
        
        let plusOneLabelsMoveUpAnimationDuration = 0.6
        let plusOneLabelsDissapearanceAnimationDuration = 0.3
        
        for var index = 0; index < plusOneLabels.count; ++index {
            let animationDelay =
            (plusOneLabelsMoveUpAnimationDuration / Double(plusOneLabels.count)) * Double(index)
            
            if let
                label = plusOneLabels[index],
                constraint = labelTopConstraint[label],
                constantMin = topConstraintMin[constraint],
                constantMax = constantMaxForConstraint(constraint) {
                    UIView.animateWithDuration(plusOneLabelsMoveUpAnimationDuration,
                        delay: animationDelay,
                        usingSpringWithDamping: 0.4,
                        initialSpringVelocity: 0.0,
                        options: .CurveLinear,
                        animations: {
                            self.showLabel(label)
                            
                            constraint.constant = CGFloat(constantMin)
                            
                            self.view.layoutIfNeeded()
                        }, completion: {
                            (finished: Bool) -> Void in
                            UIView.animateWithDuration(plusOneLabelsDissapearanceAnimationDuration,
                                animations: {
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
            animations: {
                self.signedLabelBottomConstraint.constant = bottomConst
                self.signedLabel.transform = CGAffineTransformMakeScale(1.5, 1.5)
                
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(0.3,
                    delay: 0.15,
                    options: .CurveLinear,
                    animations: {
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
    
    // MARK: -
    
    private func stringForDoubleDigitInt(doubleDigitInt: Int) -> String {
        if doubleDigitInt < 10 {
            return "0\(doubleDigitInt)"
        }
        
        return "\(doubleDigitInt)"
    }
}

extension DailyDappVC: DappBackSideLinksVCDelegate {
    func openLinkWithURL(linkURL: NSURL) {
        ViewControllerHelper.openLinkWithURL(linkURL, inViewController: self)
    }
}
