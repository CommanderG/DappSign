//
//  ScoreboardVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/29/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class ScoreboardVC: UIViewController {
    @IBOutlet weak var profileButton:               UIButton!
    @IBOutlet weak var composeButton:               UIButton!
    @IBOutlet weak var timeUntilNextDailyDappLabel: UILabel!
    @IBOutlet weak var descriptionLabel:            UILabel!
    @IBOutlet weak var hashtagsLabel:               UILabel!
    @IBOutlet weak var tweetButton:                 UIButton!
    @IBOutlet weak var showLinksButton:             UIButton!
    @IBOutlet weak var postToFacebookButton:        UIButton!
    
    internal var transitionDelegate: TransitionDelegate? = nil
    
    private var timeUntilNextDailyDappLabelUpdateTimer: NSTimer? = nil
    private var timeUntilNextDailyDappUpdateTimer: NSTimer? = nil
    private var timeUntilNextDailyDapp: (Int, Int, Int)? = nil
    private var dapps: [PFObject] = []
    private var scoreboardDappSignVC: ScoreboardDappSignVC? = nil
    private var scoreboardDappMappVC: ScoreboardDappMappVC? = nil
    private var currentDappIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewHelper.initButtonLayer(self.profileButton)
        ViewHelper.initButtonLayer(self.composeButton)
        self.updateTimeUntilNextDailyDapp()
        self.updateTimeUntilNextDailyDappLabel()
        self.initTimers()
        self.initDescriptionLabelText()
        
        self.scoreboardDappSignVC?.view.hidden = true
        self.hashtagsLabel.text = ""
        
        self.disableSharingAndLinkButtons()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ScoreboardHelper.downloadScoreboardDapps {
            (scoreboardDapps: [PFObject], error: NSError?) -> Void in
            self.dapps = scoreboardDapps
            
            if let dapp = self.dapps.first {
                self.scoreboardDappSignVC?.view.hidden = false
                self.currentDappIndex = 0
                
                self.initHashtagsLabelWithHashtagsForDapp(dapp)
                self.scoreboardDappSignVC?.showDappObject(dapp)
                self.scoreboardDappMappVC?.showDappMappDataForDapp(dapp)
                self.enableSharingAndLinkButtons()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBActions
    
    @IBAction func tweet() {
        let dappSignImage = self.scoreboardDappSignVC?.frontSideImage()
        
        if let currentDapp = self.currentDapp(), dappSignImage = dappSignImage {
            TwitterHelper.tweetDapp(currentDapp, image: dappSignImage, completion: {
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
    
    @IBAction func showLinks() {
        if let scoreboardDappSignVC = self.scoreboardDappSignVC, dapp = self.dapps.first {
            if scoreboardDappSignVC.showLinksForDapp(dapp) {
                self.disableSharingAndLinkButtons()
            }
        }
    }
    
    @IBAction func postToFacebook() {
        let dappSignImage = self.scoreboardDappSignVC?.frontSideImage()
        
        if let currentDapp = self.currentDapp(), dappSignImage = dappSignImage {
            FacebookHelper.postImageToFacebook(dappSignImage, dapp: currentDapp, completion: {
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
    
    // MARK: - init
    
    private func initTimers() {
        self.timeUntilNextDailyDappLabelUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target:   self,
            selector: "updateTimeUntilNextDailyDappLabel",
            userInfo: nil,
            repeats:  true
        )
        self.timeUntilNextDailyDappUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5,
            target:   self,
            selector: "updateTimeUntilNextDailyDapp",
            userInfo: nil,
            repeats:  true
        )
    }
    
    private func initDescriptionLabelText() {
        let attachment = NSTextAttachment()
        
        attachment.image = UIImage(named: "dapp_icon")
        attachment.bounds = CGRectMake(0.0, -5.0, 17.0, 19.0)
        
        let checkInAnyTimeBetweenStr = NSAttributedString(string: "Check in any time between ")
        let noon1pmStr = NSMutableAttributedString(string: "noon-1pm")
        let forTheStr = NSAttributedString(string: " for the ")
        let dailyNewsStr = NSMutableAttributedString(string: "daily news")
        let deliveredAsStr = NSAttributedString(string: " delivered as ")
        let petitionsStr = NSMutableAttributedString(string: "petitions")
        let aimedAtYourDistrictRepInCongressJustStr = NSAttributedString(
            string: " aimed at your district rep in congress. Just "
        )
        let dappStr = NSMutableAttributedString(string: "Dapp ")
        let dappIconStr = NSAttributedString(attachment: attachment)
        let toSignStr = NSAttributedString(string: "to sign.")
        
        if let fontAvenirHeavy = UIFont(name: "Avenir-Heavy", size: 12.0) {
            let strs = [
                noon1pmStr,
                dailyNewsStr,
                petitionsStr
            ]
            
            for str in strs {
                str.addAttribute(NSFontAttributeName,
                    value: fontAvenirHeavy,
                    range: NSMakeRange(0, str.string.characters.count)
                )
            }
        }
        
        if let fontExoBlack = UIFont(name: "Exo-Black", size: 12.0) {
            dappStr.addAttribute(NSFontAttributeName,
                value: fontExoBlack,
                range: NSMakeRange(0, dappStr.string.characters.count)
            )
        }
        
        let strs = [
            checkInAnyTimeBetweenStr,
            noon1pmStr,
            forTheStr,
            dailyNewsStr,
            deliveredAsStr,
            petitionsStr,
            aimedAtYourDistrictRepInCongressJustStr,
            dappStr,
            dappIconStr,
            toSignStr
        ]
        
        let str = NSMutableAttributedString()
        
        for str_ in strs {
            str.appendAttributedString(str_)
        }
        
        self.descriptionLabel.attributedText = str
    }
    
    // MARK: - timer functions
    
    internal func updateTimeUntilNextDailyDappLabel() {
        struct show {
            static var colon = false
        }
        
        show.colon = !show.colon
        
        if let (hours, minutes, seconds) = self.timeUntilNextDailyDapp {
            let hoursString = self.twoDigitNumberString(hours)
            let minutesString = self.twoDigitNumberString(minutes)
            let secondsString = self.twoDigitNumberString(seconds)
            
            if show.colon {
                self.timeUntilNextDailyDappLabel.text =
                "\(hoursString):\(minutesString):\(secondsString)"
            } else {
                self.timeUntilNextDailyDappLabel.text =
                "\(hoursString) \(minutesString) \(secondsString)"
            }
            
            let lessThanOneHourLeft = hours == 23 && minutes > 0
            
            if lessThanOneHourLeft {
                self.transitionDelegate?.transitionFromViewController(self)
            }
        } else {
            if show.colon {
                self.timeUntilNextDailyDappLabel.text = "--:--:--"
            } else {
                self.timeUntilNextDailyDappLabel.text = "-- -- --"
            }
        }
    }
    
    internal func updateTimeUntilNextDailyDapp() {
        if let timeInterval = DailyDappDatesHelper.timeIntervalUntilNextDailyDappStartDate() {
            self.timeUntilNextDailyDapp = DateHelper.hoursMinutesSecondsInTimeInterval(timeInterval)
        } else {
            self.timeUntilNextDailyDapp = nil
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case ScoreboardDappSignVC.embedSegueID:
                self.scoreboardDappSignVC = segue.destinationViewController as? ScoreboardDappSignVC
                
                self.scoreboardDappSignVC?.delegate = self
            case ScoreboardDappMappVC.embedSegueID:
                self.scoreboardDappMappVC = segue.destinationViewController as? ScoreboardDappMappVC
            case "showProfile":
                let profileNC = segue.destinationViewController as? UINavigationController
                let profileVC = profileNC?.viewControllers.first as? ProfileViewController
                
                profileVC?.user = PFUser.currentUser()
            case _:
                break
            }
        }
    }
    
    // MARK: - 
    
    private func twoDigitNumberString(twoDigitNumber: Int) -> String {
        if twoDigitNumber < 10 {
            return "0\(twoDigitNumber)"
        }
        
        return "\(twoDigitNumber)"
    }
    
    private func showNextDapp() {
        self.currentDappIndex = (self.currentDappIndex + 1) % self.dapps.count
        
        let currentDapp = self.currentDapp()
        
        self.disableSharingAndLinkButtons()
        
        if let currentDapp = currentDapp {
            self.scoreboardDappSignVC?.moveRighOffTheScreen {
                self.initHashtagsLabelWithHashtagsForDapp(currentDapp)
                self.scoreboardDappSignVC?.showDappObject(currentDapp)
                self.enableSharingAndLinkButtons()
            }
        }
        
        self.scoreboardDappMappVC?.showDappMappDataForDapp(currentDapp)
    }
    
    private func currentDapp() -> PFObject? {
        if (self.currentDappIndex < 0 || self.currentDappIndex >= self.dapps.count) {
            return nil
        }
        
        let dapp = self.dapps[self.currentDappIndex]
        
        return dapp
    }
    
    private func initHashtagsLabelWithHashtagsForDapp(dapp: PFObject) {
        self.hashtagsLabel.text = ""
        
        DappsHelper.downloadHashtagsForDapp(dapp) {
            (hashtags: [PFObject]?, error: NSError?) -> Void in
            if let
                hashtags = hashtags,
                currentDapp = self.currentDapp() {
                    if dapp.objectId == currentDapp.objectId {
                        let hashtagsString = HashtagHelper.hashtagNamesStringWithHashtags(hashtags)
                        
                        self.hashtagsLabel.text = hashtagsString
                        
                        return
                    }
            }
            
            self.hashtagsLabel.text = ""
        }
    }
    
    private func disableSharingAndLinkButtons() {
        ViewHelper.disableButton(self.tweetButton)
        ViewHelper.disableButton(self.showLinksButton)
        ViewHelper.disableButton(self.postToFacebookButton)
    }
    
    private func enableSharingAndLinkButtons() {
        ViewHelper.enableButton(self.tweetButton)
        ViewHelper.enableButton(self.showLinksButton)
        ViewHelper.enableButton(self.postToFacebookButton)
    }
}

extension ScoreboardVC: ScoreboardDappSignDelegate {
    func willFlipToSide(side: DappSignSide) {
        switch side {
        case .Front:
            break;
        case .Back:
            self.disableSharingAndLinkButtons()
        }
    }
    
    func didFlipToSide(side: DappSignSide) {
        switch side {
        case .Front:
            self.enableSharingAndLinkButtons()
        case .Back:
            break;
        }
    }
    
    func didFinishCountingDown() {
        self.showNextDapp()
    }
    
    func openLinkWithURL(linkURL: NSURL) {
        ViewControllerHelper.openLinkWithURL(linkURL, inViewController: self)
    }
    
    func didCloseLinksView() {
        self.enableSharingAndLinkButtons()
    }
}
