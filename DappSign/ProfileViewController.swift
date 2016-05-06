//
//  ProfileViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    internal var user: PFUser?
    
    @IBOutlet weak var dappScoreLabel: UILabel!
    @IBOutlet weak var nameLabel:      UILabel!
    @IBOutlet weak var adminButton:    UIButton!
    @IBOutlet weak var changeButton:   UIButton!
    
    private var dapps: [PFObject] = []
    private var petitionsTVC: PetitionsTVC? = nil
    private var segmentsVC: SegmentsVC? = nil
    
    private var editLinksSegueID = "editLinksSegue"
    private var dappLinkEdit: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewHelper.initButtonLayer(self.changeButton)
        
        nameLabel.text = self.user?["name"] as? String
        
        self.initDappScoreLabel()
        self.initAdminButton()
        self.downloadDapps()
        self.petitionsTVC?.showDapps([], showEditLinksButton: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
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
//        if let currentUser = PFUser.currentUser() {
//            let mainBundle = NSBundle.mainBundle()
//            let adminUsersIDs = mainBundle.objectForInfoDictionaryKey("AdminUsersIDs") as? [String]
//            
//            if let adminUsersIDs = adminUsersIDs, user = self.user {
//                if !adminUsersIDs.contains(currentUser.objectId) ||
//                    user.objectId != currentUser.objectId {
//                        self.adminButton.hidden = true
//                }
//            } else {
//                self.adminButton.hidden = true
//            }
//        } else {
//            self.adminButton.hidden = true
//        }
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
            case _:
                break;
            }
        }
    }
    
    // MARK: - @IBActions
    
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
                self.downloadDappsSwipedByUser {
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
    
    private func downloadDappsSwipedByUser(completion: (dapps: [PFObject]) -> Void) {
        if let user = self.user {
            Requests.downloadDappsSwipedByUser(user, completion: {
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
}

extension ProfileViewController: SegmentsDelegate {
    func didSelectSegment(segment: Segment) {
        self.downloadDapps()
    }
}
