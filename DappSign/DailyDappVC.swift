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

struct LabelAnimationInfo {
    let label: UILabel!
    let topLC: NSLayoutConstraint!
    let maxTopSpaceConstraint: CGFloat
    let minTopSpaceConstraint: CGFloat
}

class DailyDappVC: UIViewController {
    @IBOutlet weak var dappViewsContainerView     : SwipeableView!
    @IBOutlet weak var dappSignView               : UIView!
    @IBOutlet weak var dappMappView               : UIView!
    @IBOutlet weak var tweetThisCardButton        : UIButton!
    @IBOutlet weak var showLinksButton            : UIButton!
    @IBOutlet weak var shareOnFacebookButton      : UIButton!
    @IBOutlet weak var profileButton              : UIButton!
    @IBOutlet weak var composeButton              : UIButton!
    @IBOutlet weak var searchButton               : UIButton!
    @IBOutlet weak var dappScoreLabel             : UILabel!
    @IBOutlet weak var plusDappsCountLabel        : UILabel!
    @IBOutlet weak var plusOneRepresentativeLabel : UILabel!
    @IBOutlet weak var signedLabel                : UILabel!
    @IBOutlet weak var hashtagsLabel              : UILabel!
    @IBOutlet weak var dailyDappTimeLeftLabel     : UILabel!
    @IBOutlet weak var topContainerView           : UIView!
    @IBOutlet weak var oneMinuteLeftLabel         : UILabel!
    @IBOutlet weak var dailyDappBeginsInLabel     : UILabel!
    
    @IBOutlet weak var plusDappsCountLabelTopConstraint        : NSLayoutConstraint!
    @IBOutlet weak var plusOneRepresentativeLabelTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var signedLabelBottomConstraint             : NSLayoutConstraint!
    @IBOutlet weak var oneMinuteLeftLabelBottomLC              : NSLayoutConstraint!
    @IBOutlet weak var dailyDappBeginsInLabelBottomLC          : NSLayoutConstraint!
    
    internal var transitionDelegate: TransitionDelegate? = nil
    
    private var dappSignVC                        : DappSignVC?          = nil
    private var dappMappVC                        : DappMappVC?          = nil
    private var representativeVC                  : RepresentativeVC?    = nil
    private var visibleDappView                   : UIView!              = nil
    private var lastDappedDapp                    : PFObject?            = nil
    private var dappBackSideLinksVC               : DappBackSideLinksVC? = nil
    private var dailyDappTimeLeftLabelUpdateTimer : NSTimer?             = nil
    private var dailyDappTimeLeftUpdateTimer      : NSTimer?             = nil
    private var dailyDappTimeLeft                 : (Int, Int)?          = nil
    private var animatingPlusOneLabels            : Bool                 = false
    private var dapps                             : [PFObject]           = []
    private var lastIntroductoryDappID            : String?              = nil
    private var timer                             : NSTimer?             = nil
    private var currentDappCardType               : DappCardType         = .DappCardTypeSign
    private var animateableViews                  : [UIView]!            = []
    private var dappScore                         : Int?                 = nil
    private var labelsAnimationInfo               : [LabelAnimationInfo] = []
    
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
        self.dappViewsContainerView.appearanceDelegate = self
        self.dappViewsContainerView.movementDelegate = self
        self.dappViewsContainerView.minTranslationX = 150.0;
        
        self.showDappView(self.dappSignView)
        
        if PFUser.currentUser() == nil {
            self.profileButton.hidden = true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("handleDappSwipedNotification:"),
            name: DappSwipedNotification,
            object: nil
        )
        
        let labels: [UIView] = [
            self.plusDappsCountLabel,
            self.plusOneRepresentativeLabel,
            self.signedLabel,
            self.oneMinuteLeftLabel,
            self.dailyDappBeginsInLabel
        ]
        
        ViewHelper.hideViews(labels)
        
        self.hashtagsLabel.text = ""
        
        self.initAnimateableViews()
        
        if let representativeVC = self.representativeVC {
            representativeVC.view.alpha = 0.0
        }
        
        self.dappScoreLabel.alpha = 0.0
        
        let plusOneDappsCountLabelAnimationInfo = LabelAnimationInfo(
            label: self.plusDappsCountLabel,
            topLC: self.plusDappsCountLabelTopConstraint,
            maxTopSpaceConstraint: -75.0,
            minTopSpaceConstraint: -75.0 + 80.0
        )
        
        let plusOneRepresentativeLabelAnimationInfo = LabelAnimationInfo(
            label: self.plusOneRepresentativeLabel,
            topLC: self.plusOneRepresentativeLabelTopConstraint,
            maxTopSpaceConstraint: -15.0,
            minTopSpaceConstraint: -15.0 + 80.0
        )
        
        self.labelsAnimationInfo = [
            plusOneDappsCountLabelAnimationInfo,
            plusOneRepresentativeLabelAnimationInfo
        ]
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
        
        for view in self.animateableViews {
            view.alpha = 0.0
        }
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
        
        self.hideLabel(self.signedLabel, labelBottomLC: self.signedLabelBottomConstraint)
        self.hideLabel(self.oneMinuteLeftLabel, labelBottomLC: self.oneMinuteLeftLabelBottomLC)
        self.hideLabel(self.dailyDappBeginsInLabel,
            labelBottomLC: self.dailyDappBeginsInLabelBottomLC
        )
        
        for labelAnimationInfo in self.labelsAnimationInfo {
            let topLC = labelAnimationInfo.topLC
            let maxTopSpaceConstraint = labelAnimationInfo.maxTopSpaceConstraint
            
            topLC.constant = maxTopSpaceConstraint
        }
        
        self.animateAnimateableViews()
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
                view2: dappBackSideLinksVC.view,
                completion: {
                    self.disableShareButons()
                }
            )
            
            dappBackSideLinksVC.showLinksForDapp(dapp)
        }
    }
    
    @IBAction func handleDappLinksTapGesture(tapGR: UITapGestureRecognizer) {
        if let dappBackSideLinksView = self.dappBackSideLinksVC?.view {
            self.flipWithDuration(self.flipDuration,
                view1: self.dappViewsContainerView,
                view2: dappBackSideLinksView,
                completion: {
                    self.enableShareButtons()
                }
            )
        }
    }
    
    @IBAction func postCurrentDappCardToFacebook(sender: AnyObject) {
        if let dapp = self.dapps.first {
            FacebookHelper.shareDapp(dapp, completion: {
                (message: String) -> Void in
                self.showAlertViewWithOKButtonAndMessage(message)
            })
        }
    }
    
    @IBAction func tweetCurrentDappCard(sender: AnyObject) {
        if let currentDapp = self.dapps.first {
            TwitterHelper.tweetDapp(currentDapp, completion: {
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
            embedDappVC.delegate = self
            
            self.addChildViewController(embedDappVC)
            
            let frame = embedDappVC.frameWithDappViewFrame(self.dappViewsContainerView.frame)
            
            embedDappVC.view.frame = frame
            
            self.dappViewsContainerView.addSubview(embedDappVC.view)
            
            embedDappVC.didMoveToParentViewController(self)
            embedDappVC.showURLAndIFrameCodeForDappWithID(dapp.objectId)
            embedDappVC.show()
            self.disableShareButons()
        }
    }
    
    // MARK: -
    
    private func flipWithDuration(duration: NSTimeInterval,
        view1: UIView,
        view2: UIView,
        completion: (Void -> Void)?
    ) {
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
        
        delay(duration) {
            completion?()
        }
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
            case DappSignVC.embedSegueID:
                self.dappSignVC = segue.destinationViewController as? DappSignVC
            case "embedDappMappVC":
                self.dappMappVC = segue.destinationViewController as? DappMappVC
            case RepresentativeVC.embedSegueID:
                self.representativeVC = segue.destinationViewController as? RepresentativeVC
                
                self.representativeVC?.delegate = self
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
            if let user = user, newDappScore = user["dappScore"] as? Int {
                if let dappScore = self.dappScore {
                    if dappScore < newDappScore {
                        let deltaDappScore = newDappScore - dappScore
                        
                        self.plusDappsCountLabel.text = "+\(deltaDappScore)"
                        
                        self.showDappScorePlusOneLabel {
                            self.plusDappsCountLabel.text = "+1"
                        }
                    }
                } else {
                    self.dappScoreLabel.alpha = 1.0
                    
                    AnimationHelper.showView(self.dappScoreLabel)
                    self.initAnimateableViews()
                }
                
                self.dappScore = newDappScore
            }
            
            var dappScoreStr = ""
            
            if let user = user, dappScore = user["dappScore"] as? Int {
                dappScoreStr = "\(dappScore)"
            } else {
                dappScoreStr = "-"
            }
            
            let dappScoreLabelText = dappScoreStr + " Dapp"
            let attributedString = NSMutableAttributedString(string: dappScoreLabelText)
            let fontAvenirBook = UIFont(name: "Avenir-Book", size: 18.0)
            let fontExoBlack = UIFont(name: "Exo-Black", size: 19.0)
            
            if let fontAvenirBook = fontAvenirBook, fontExoBlack = fontExoBlack {
                attributedString.addAttribute(NSFontAttributeName,
                    value: fontAvenirBook,
                    range: NSMakeRange(0, dappScoreStr.characters.count)
                )
                attributedString.addAttribute(NSFontAttributeName,
                    value: fontExoBlack,
                    range: NSMakeRange(dappScoreStr.characters.count, " Dapp".characters.count)
                )
            }
            
            self.dappScoreLabel.attributedText = attributedString
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
            
            if let (minutes, seconds) = self.dailyDappTimeLeft {
                if (minutes == 1 && seconds == 0) {
                    self.showCountdownLabel(self.oneMinuteLeftLabel,
                        countdownLabelBottomLC: self.oneMinuteLeftLabelBottomLC
                    )
                } else if (minutes == 0) {
                    if (seconds == 6) {
                        self.showCountdownLabel(self.dailyDappBeginsInLabel,
                            countdownLabelBottomLC: self.dailyDappBeginsInLabelBottomLC
                        )
                    } else if (seconds < 6 && seconds > 0) {
                        
                    }
                }
            }
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
    
    private func hideLabel(label: UILabel!, labelBottomLC: NSLayoutConstraint!) {
        let labelHeight = CGRectGetHeight(label.frame)
        
        labelBottomLC.constant = -labelHeight
    }
    
    private func performDappAnimationsWithCompletion(completion: Void -> Void) {
        if self.animatingPlusOneLabels {
            return
        }
        
        self.animatingPlusOneLabels = true
        
        self.showPlusOneLabels {
            self.animatingPlusOneLabels = false
            
            completion()
        }
    }
    
    private func showPlusOneLabels(completion: Void -> Void) {
        let animationDuration = 0.6
        
        for var index = 0; index < self.labelsAnimationInfo.count; ++index {
            let labelsCount = Double(self.labelsAnimationInfo.count)
            let animationDelay = animationDuration / labelsCount * Double(index)
            let animationInfo = self.labelsAnimationInfo[index]
            
            UIView.animateWithDuration(animationDuration,
                delay: animationDelay,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.0,
                options: .CurveLinear,
                animations: {
                    ViewHelper.showViews([ animationInfo.label ])
                    
                    animationInfo.topLC.constant = animationInfo.minTopSpaceConstraint
                    
                    self.view.layoutIfNeeded()
                }, completion: {
                    (finished: Bool) -> Void in
                    UIView.animateWithDuration(0.3,
                        animations: {
                            ViewHelper.hideViews([ animationInfo.label ])
                        }, completion: {
                            (finished: Bool) -> Void in
                            animationInfo.topLC.constant = animationInfo.maxTopSpaceConstraint
                            
                            if let lastAnimationInfo = self.labelsAnimationInfo.last {
                                if lastAnimationInfo.label == animationInfo.label {
                                    completion()
                                }
                            }
                        }
                    )
                }
            )
        }
    }
    
    private func showLabel(label: UILabel!,
        bottomLC: NSLayoutConstraint!,
        completion: (Void -> Void)? = nil
    ) {
        let viewHeight = CGRectGetHeight(self.view.frame)
        let labelHeight = CGRectGetHeight(label.frame)
        let bottomConst = (viewHeight - labelHeight) / 2
        
        ViewHelper.showViews([ label ])
        
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.0,
            options: .CurveLinear,
            animations: {
                bottomLC.constant = bottomConst
                
                label.transform = CGAffineTransformMakeScale(1.5, 1.5)
                
                self.view.layoutIfNeeded()
            }, completion: {
                (finished: Bool) -> Void in
                UIView.animateWithDuration(0.3,
                    delay: 0.15,
                    options: .CurveLinear,
                    animations: {
                        ViewHelper.hideViews([ label ])
                    }, completion: {
                        (finished: Bool) -> Void in
                        self.hideLabel(label, labelBottomLC: bottomLC)
                        
                        label.transform = CGAffineTransformIdentity
                        
                        completion?()
                    }
                )
            }
        )
    }
    
    private func showDappScorePlusOneLabel(completion: Void -> Void) {
        let animationDuration = 0.6
        
        var plusOneDappsCountLabelAnimationInfo: LabelAnimationInfo? = nil
        
        for labelAnimationInfo in self.labelsAnimationInfo {
            if labelAnimationInfo.label == self.plusDappsCountLabel {
                plusOneDappsCountLabelAnimationInfo = labelAnimationInfo
                
                break
            }
        }
        
        if let animationInfo = plusOneDappsCountLabelAnimationInfo {
            UIView.animateWithDuration(animationDuration,
                delay: 0.0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.0,
                options: .CurveLinear,
                animations: {
                    ViewHelper.showViews([ animationInfo.label ])
                    
                    animationInfo.topLC.constant = animationInfo.minTopSpaceConstraint
                    
                    self.view.layoutIfNeeded()
                }, completion: {
                    (finished: Bool) -> Void in
                    UIView.animateWithDuration(0.3,
                        animations: {
                            ViewHelper.hideViews([ animationInfo.label ])
                        }, completion: {
                            (finished: Bool) -> Void in
                            animationInfo.topLC.constant = animationInfo.maxTopSpaceConstraint
                        }
                    )
                }
            )
        }
    }
    
    private func showCountdownLabel(countdownLabel: UILabel!,
        countdownLabelBottomLC: NSLayoutConstraint!,
        completion: (Void -> Void)? = nil
    ) {
        struct CountdownLabel {
            static var canBeShown = true
        }
        
        if !CountdownLabel.canBeShown {
            return
        }
        
        CountdownLabel.canBeShown = false
        
        self.hideTopUI()
        self.hideBottomUI()
        
        self.dappViewsContainerView.hidden = true
        
        self.showLabel(countdownLabel,
            bottomLC: countdownLabelBottomLC,
            completion: {
                CountdownLabel.canBeShown = true
                
                self.showTopUI()
                self.showBottomUI()
                
                self.dappViewsContainerView.hidden = false
                
                completion?()
            }
        )
    }
    
    // MARK: -
    
    private func animateAnimateableViews() {
        var delaySeconds = 0.0
        
        for view in self.animateableViews {
            delaySeconds += 0.1
            
            delay(delaySeconds) {
                view.alpha = 1.0
                
                AnimationHelper.showView(view, delay: delay)
            }
        }
    }
    
    private func initAnimateableViews() {
        self.animateableViews = [
            self.profileButton,
            self.composeButton
        ]
        
        if let _ = self.dappScore {
            self.animateableViews.append(self.dappScoreLabel)
        }
        
        if let representativeVC = self.representativeVC {
            if representativeVC.downloaded {
                self.animateableViews.append(representativeVC.view)
            }
        }
        
        let sharingButtons: [UIView]! = [
            self.tweetThisCardButton,
            self.showLinksButton,
            self.shareOnFacebookButton
        ]
        
        self.animateableViews.appendContentsOf(sharingButtons)
    }
    
    private func stringForDoubleDigitInt(doubleDigitInt: Int) -> String {
        if doubleDigitInt < 10 {
            return "0\(doubleDigitInt)"
        }
        
        return "\(doubleDigitInt)"
    }
    
    private func disableShareButons() {
        let shareButtons = self.shareButtons()
        
        ViewHelper.disableButtons(shareButtons)
    }
    
    private func enableShareButtons() {
        let shareButtons = self.shareButtons()
        
        ViewHelper.enableButtons(shareButtons)
    }
    
    private func shareButtons() -> [UIButton!] {
        let shareButtons = [
            self.tweetThisCardButton, self.showLinksButton, self.shareOnFacebookButton
        ]
        
        return shareButtons
    }
}

extension DailyDappVC: DappBackSideLinksVCDelegate {
    func openLinkWithURL(linkURL: NSURL) {
        ViewControllerHelper.openLinkWithURL(linkURL, inViewController: self)
    }
}

extension DailyDappVC: RepresentativeDelegate {
    func didDownloadNewRepresentativeData(newData: Bool) {
        if !newData {
            return
        }
        
        if let representativeVC = self.representativeVC {
            if self.animateableViews.contains(representativeVC.view) {
                return
            }
            
            representativeVC.view.alpha = 1.0
            
            AnimationHelper.showView(representativeVC.view)
            self.initAnimateableViews()
        }
    }
}

extension DailyDappVC: SwipeableViewAppearanceDelegate {
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
}

extension DailyDappVC: SwipeableViewMovementDelegate {
    func didSwipe(swipeDirection: SwipeDirection) {
        if (self.visibleDappView == self.dappSignView) {
            let dapped = (swipeDirection == SwipeDirection.LeftToRight)
            
            if let currentDapp = self.dapps.first {
                self.lastDappedDapp = currentDapp
                
                self.sendRequestsForDapp(currentDapp, dapped: dapped)
                
                if dapped {
                    self.showLabel(self.signedLabel, bottomLC: self.signedLabelBottomConstraint)
                    UIView.animateWithDuration(0.4,
                        animations: {
                            self.dappViewsContainerView.alpha = 0.0
                        }, completion: { (finished: Bool) -> Void in
                            self.performDappAnimationsWithCompletion({
                                self.dappViewsContainerView.alpha = 1.0
                                self.currentDappCardType = DappCardType.DappCardTypeMapp
                                
                                self.dappViewsContainerView.show()
                                self.showBottomUI()
                            })
                        }
                    )
                } else {
                    self.currentDappCardType = DappCardType.DappCardTypeSign
                    
                    self.initTimersAfterCheckingLastIntroductoryDappID()
                    self.showBottomUI()
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
            self.showBottomUI()
        }
    }
    
    func didChangeDistanceFromCenter(dx: CGFloat, andDeltaY dy: CGFloat) {
        if self.visibleDappView != self.dappSignView {
            return
        }
        
        if let minTranslationX = self.dappViewsContainerView.minTranslationX {
            if dx > 0.0 {
                let viewHeight = CGRectGetHeight(self.view.frame)
                let signedLabelHeight = CGRectGetHeight(self.signedLabel.frame)
                let signedLabelMaxBottomConstraint = (viewHeight / 2 - signedLabelHeight / 2) * 0.4
                let signedLabelBottomConstraint =
                (dx / minTranslationX) * signedLabelMaxBottomConstraint - signedLabelHeight
                
                ViewHelper.showViews([ self.signedLabel ])
                
                self.signedLabelBottomConstraint.constant = signedLabelBottomConstraint
            }
        }
    }
    
    func didStartMoving() {
        self.hideTopUI()
        self.hideBottomUI()
    }
    
    func didStopMoving(swiped: Bool) {
        self.showTopUI()
        
        if !swiped {
            self.showBottomUI()
        }
    }
    
    func willSnapBack() {
        spring(0.5) {
            self.hideLabel(self.signedLabel, labelBottomLC: self.signedLabelBottomConstraint)
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - private
    
    private func hideTopUI() {
        self.topContainerView.hidden = true
        self.dappScoreLabel.hidden = true
        self.representativeVC?.view.hidden = true
        self.hashtagsLabel.hidden = true
    }
    
    private func showTopUI() {
        self.topContainerView.hidden = false
        self.dappScoreLabel.hidden = false
        self.representativeVC?.view.hidden = false
        self.hashtagsLabel.hidden = false
    }
    
    private func hideBottomUI() {
        self.tweetThisCardButton.hidden = true
        self.showLinksButton.hidden = true
        self.shareOnFacebookButton.hidden = true
    }
    
    private func showBottomUI() {
        self.tweetThisCardButton.hidden = false
        self.showLinksButton.hidden = false
        self.shareOnFacebookButton.hidden = false
    }
}

extension DailyDappVC: EmbedDappDelegate {
    func didRemoveFromParentViewController() {
        self.enableShareButtons()
    }
}
