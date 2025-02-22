//
//  ProfileViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var dappScoreLabel : UILabel!
    @IBOutlet weak var nameLabel      : UILabel!
    @IBOutlet weak var adminButton    : UIButton!
    @IBOutlet weak var changeButton   : UIButton!
    
    @IBOutlet weak var representativeContainerViewWidthLC: NSLayoutConstraint!
    
    internal var user: PFUser? = nil
    
    private var dapps            : [PFObject]        = []
    private var representative   : PFObject?         = nil
    private var petitionsTVC     : PetitionsTVC?     = nil
    private var segmentsVC       : SegmentsVC?       = nil
    private var representativeVC : RepresentativeVC? = nil
    private var editLinksSegueID : String            = "editLinksSegue"
    private var dappLinkEdit     : PFObject?         = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors.getViewControllerBackgroundColor()
        
        ViewHelper.initButtonLayer(self.changeButton)
        
        nameLabel.text = self.user?["name"] as? String ?? ""
        
        self.initDappScoreLabel()
        self.initAdminButton()
        self.downloadDapps()
        self.petitionsTVC?.showDapps([], showEditLinksButton: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        
        self.representative = nil
        
        if let userID = user?.objectId {
            Requests.downloadRepresentativesForUserWithID(userID, completion: {
                (representatives: [PFObject]?, error: NSError?) -> Void in
                self.representative = representatives?.first
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - init
    
    private func initDappScoreLabel() {
        self.dappScoreLabel.text = "0 Dapp"
        
        let currentUserID = PFUser.currentUser().objectId
        
        Requests.userWithID(currentUserID) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user, dappScore = user["dappScore"] as? Int {
                self.dappScoreLabel.text = "\(dappScore) Dapp"
            } else {
                self.dappScoreLabel.text = "0 Dapp"
            }
        }
    }
    
    private func initAdminButton() {
        guard let currentUser = PFUser.currentUser() else {
            self.adminButton.hidden = true
            
            return
        }
        
        let mainBundle = NSBundle.mainBundle()
        
        guard
            let adminUsersIDs = mainBundle.objectForInfoDictionaryKey("AdminUsersIDs") as? [String],
            let user = self.user
            else {
                self.adminButton.hidden = true
                
                return
        }
        
        if !adminUsersIDs.contains(currentUser.objectId) || user.objectId != currentUser.objectId {
            self.adminButton.hidden = true
        }
    }
    
    // MARK: -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueID = segue.identifier {
            switch segueID {
            case self.editLinksSegueID:
                let editDappLinksVC = segue.destinationViewController as? EditDappLinksVC
                
                editDappLinksVC?.dapp = self.dappLinkEdit
            case PetitionsTVC.embedSegueID:
                self.petitionsTVC = segue.destinationViewController as? PetitionsTVC
                
                self.petitionsTVC?.delegate = self
                self.petitionsTVC?.user = self.user
            case SegmentsVC.embedSegueID:
                self.segmentsVC = segue.destinationViewController as? SegmentsVC
                
                self.segmentsVC?.delegate = self
            case RepresentativeVC.embedSegueID:
                self.representativeVC = segue.destinationViewController as? RepresentativeVC
                
                self.representativeVC?.delegate = self
            case _:
                break;
            }
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction func showRepresentativeFacebookProfile() {
        if let representative = self.representative {
            if let URL = RepresentativeHelper.facebookProfileURLForRepresentative(representative) {
                ViewControllerHelper.openLinkWithURL(URL, inViewController: self)
            }
        }
    }
    
    @IBAction func showRepresentativeTwitterProfile() {
        if let representative = self.representative {
            if let URL = RepresentativeHelper.twitterProfileURLForRepresentative(representative) {
                ViewControllerHelper.openLinkWithURL(URL, inViewController: self)
            }
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Requests
    
    private func downloadDapps() {
        if let segmentsVC = self.segmentsVC {
            switch segmentsVC.selectedSegment {
            case Segment.PetitionsSubmitted:
                self.downloadDappsCreatedByUser {
                    (dapps: [PFObject]) -> Void in
                    self.dapps = dapps
                    
                    self.petitionsTVC?.showDapps(dapps, showEditLinksButton: true)
                }
            case Segment.PetitionsSigned:
                self.downloadDappsDappedByUser {
                    (dapps: [PFObject]) -> Void in
                    self.dapps = dapps
                    
                    self.petitionsTVC?.showDapps(dapps, showEditLinksButton: false)
                }
            }
        }
    }
    
    private func downloadDappsCreatedByUser(completion: (dapps: [PFObject]) -> Void) {
        if let user = self.user {
            Requests.downloadDappsCreatedByUserWithId(user.objectId, completion: {
                (dapps: [PFObject], error: NSError!) -> Void in
                if let error = error {
                    self.showAlertViewWithOKButtonAndMessage(error.localizedDescription)
                    
                    completion(dapps: [])
                } else {
                    completion(dapps: dapps)
                }
            })
        } else {
            completion(dapps: [])
        }
    }
    
    private func downloadDappsDappedByUser(completion: (dapps: [PFObject]) -> Void) {
        if let user = self.user {
            Requests.downloadDappsDappedByUser(user, completion: {
                (dapps: [PFObject], error: NSError!) -> Void in
                if let error = error {
                    self.showAlertViewWithOKButtonAndMessage(error.localizedDescription)
                    
                    completion(dapps: [])
                } else {
                    completion(dapps: dapps)
                }
            })
        } else {
            completion(dapps: [])
        }
    }
}

extension ProfileViewController: PetitionsDelegate {
    func editLinks(dapp: PFObject) {
        self.dappLinkEdit = dapp
        
        self.performSegueWithIdentifier(self.editLinksSegueID, sender: self)
    }
    
    func resubmitDapp(dapp: PFObject) {
        DappArraysHelper.addDapp(dapp, toArray: .Secondary) {
            (error: NSError?) -> Void in
            if let error = error {
                print(error)
            } else {
                let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                progressHUD.mode = MBProgressHUDMode.Text
                progressHUD.labelText = "Resubmitted"
                
                delay(0.75) {
                    progressHUD.hide(true)
                }
            }
        }
    }
}

extension ProfileViewController: SegmentsDelegate {
    func didSelectSegment(segment: Segment) {
        self.downloadDapps()
    }
}

extension ProfileViewController: RepresentativeDelegate {
    func didDownloadNewRepresentativeData(newData: Bool) {
        if !newData {
            return
        }
        
        if let fullNameLabel = self.representativeVC?.fullNameLabel {
            let fullNameLabelHeight = CGRectGetHeight(fullNameLabel.frame)
            let sizeToFit = CGSizeMake(CGFloat.max, fullNameLabelHeight)
            let fullNameLabelSize = fullNameLabel.sizeThatFits(sizeToFit)
            
            self.representativeContainerViewWidthLC.constant = fullNameLabelSize.width
        }
    }
}
