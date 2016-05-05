//
//  PetitionsTVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 4/29/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol PetitionsDelegate {
    func editLinks(dapp: PFObject)
}

class PetitionsTVC: UITableViewController {
    internal static let embedSegueID = "embedPetitionsTVC"
    
    internal var user: PFUser? = nil
    internal var delegate: PetitionsDelegate? = nil
    
    private var dappsIdsSwipedByLoggedInUser: [String]? = nil
    private var dapps: [PFObject] = []
    private var showEditLinksButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadDappsSwipedByUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func showDapps(dapps: [PFObject], showEditLinksButton: Bool) {
        self.dapps = dapps
        self.showEditLinksButton = showEditLinksButton
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dapps.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! DappProfileCell
        
        cell.cellDelegate = self
        
        let dapp = self.dapps[indexPath.row]
        
        cell.dappSignView.showDappObject(dapp)
        
        if self.showEditLinksButton {
            cell.resubmitButton.hidden = false
            cell.editLinksButton.hidden = false
        } else {
            cell.resubmitButton.hidden = true
            cell.editLinksButton.hidden = true
        }
        
        if self.canShowDappButtonInCellWithDappWithId(dapp.objectId) {
            let buttons = NSMutableArray(capacity: 1)
            
            buttons.sw_addUtilityButtonWithColor(
                UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0),
                title: "Dapp"
            )
            
            cell.leftUtilityButtons = buttons as [AnyObject]
            cell.delegate = self
        } else {
            cell.leftUtilityButtons = []
            cell.delegate = nil
        }
        
        cell.showDappMappDataForDapp(dapp)
        
        return cell
    }
    
    // MARK: -
    
    private func downloadDappsSwipedByUser() {
        if let user = self.user, currentUser = PFUser.currentUser() {
            if user.objectId != currentUser.objectId {
                Requests.downloadDappsSwipedByUser(PFUser.currentUser(), completion: {
                    (dapps: [PFObject], error: NSError!) -> Void in
                    if error != nil {
                        print(error)
                        
                        return
                    }
                    
                    self.dappsIdsSwipedByLoggedInUser = dapps.map({ $0.objectId })
                })
            }
        }
    }
    
    private func canShowDappButtonInCellWithDappWithId(dappId: String) -> Bool {
        if self.user?.objectId == PFUser.currentUser().objectId {
            return false
        }
        
        if let dappsIdsSwipedByLoggedInUser = self.dappsIdsSwipedByLoggedInUser {
            if dappsIdsSwipedByLoggedInUser.contains(dappId) {
                return false
            }
        }
        
        return true
    }
    
    private func dapp(dapp: PFObject, completion: (succeeded: Bool) -> Void) {
        let currentUser = PFUser.currentUser()
        
        Requests.addDappToDappsSwipedArray(dapp, user: currentUser, completion: {
            (succeeded: Bool, error: NSError?) -> Void in
            var message: String
            
            if succeeded {
                message = "You have successfully dapped this card."
                
                self.dappsIdsSwipedByLoggedInUser?.append(dapp.objectId)
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                
                notificationCenter.postNotificationName(DappSwipedNotification,
                    object: dapp.objectId
                )
                
                Requests.incrementScoreOfTheDapp(dapp, completion: {
                    (succeeded: Bool, error: NSError?) -> Void in
                })
            } else if let error = error {
                message = "Failed to dapp this card. Error: \(error.localizedDescription)"
            } else {
                message = "Failed to dapp this card. Unknown error."
            }
            
            self.showAlertViewWithOKButtonAndMessage(message)
            
            completion(succeeded: succeeded)
        })
    }
}

extension PetitionsTVC: DappProfileCellDelegate {
    func editLinkInCell(cell: DappProfileCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if indexPath.row < dapps.count {
                let dapp = self.dapps[indexPath.row]
                
                self.delegate?.editLinks(dapp)
            }
        }
    }
    
    func resubmitDappInCell(cell: DappProfileCell) {
        
    }
}

extension PetitionsTVC: SWTableViewCellDelegate {
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!,
        didTriggerLeftUtilityButtonWithIndex index: Int
    ) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            let dapp = self.dapps[indexPath.row];
            
            self.dapp(dapp, completion: {
                (succeeded: Bool) -> Void in
                if succeeded {
                    self.incrementDappScores(dapp)
                }
                
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            })
            
            cell.hideUtilityButtonsAnimated(true)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
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
}
