//
//  ProfileViewController.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    internal var user: PFUser!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var publicPrivateLabel: UILabel!
    @IBOutlet weak var numDappsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dappsFilterSegmentedControl: UISegmentedControl!
    
    //design
    var dappColors = DappColors()
    var dappFonts = DappFonts()
    
    var dappsIdsSwipedByLoggedInUser: [String]? = nil
    var dappsCreatedByUserInProfile: [PFObject]? = nil
    var dappsSwipedByUserInProfile: [PFObject]? = nil
    
    private var editLinksSegueID = "editLinksSegue"
    private var selectedDappSegue: PFObject?
    
    enum DappsFilter: Int {
        case DappSigns = 0
        case Dapped = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.user.objectId != PFUser.currentUser().objectId {
            Requests.downloadDappsSwipedByUser(PFUser.currentUser(), completion: {
                (dapps: [PFObject], error: NSError!) -> Void in
                if error != nil {
                    print(error)
                    
                    return
                }
                
                self.dappsIdsSwipedByLoggedInUser = dapps.map({ $0.objectId })
            })
        }
        
        if let font = UIFont(name: "Exo-Regular", size: 18.0) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
        }
        
        if let font = UIFont(name: "Exo-Regular", size: 16.0) {
            self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(
                [NSFontAttributeName: font],
                forState: .Normal
            )
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(
                [NSFontAttributeName: font],
                forState: .Normal
            )
        }
        
        if let imageData = user["image"] as? NSData {
            profilePic.image = UIImage(data: imageData)
        }
        
        nameLabel.text = user["name"] as? String
        
        if let currentUser = PFUser.currentUser() {
            let mainBundle = NSBundle.mainBundle()
            
            if let adminUsersIDs = mainBundle.objectForInfoDictionaryKey("AdminUsersIDs") as? [String] {
                if !adminUsersIDs.contains(currentUser.objectId) || self.user.objectId != currentUser.objectId {
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.downloadDapps()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.editLinksSegueID {
            let editDappLinksVC = segue.destinationViewController as? EditDappLinksVC
            editDappLinksVC?.dapp = self.selectedDappSegue
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dappsFilterSegmentedControlValueChanged(sender: AnyObject) {
        if self.dapps() != nil {
            self.tableView.reloadData()
        } else {
            self.downloadDapps()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dapps = self.dapps() {
            return dapps.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! DappProfileCell
        
        cell.cellDelegate = self
        
        if let dapps = self.dapps() {
            let dapp = dapps[indexPath.row]
            
            cell.dappSignView.showDappObject(dapp)
            
            if self.dappsFilterSegmentedControl.selectedSegmentIndex == DappsFilter.DappSigns.rawValue {
                cell.editLinksView.hidden = false
            } else {
                cell.editLinksView.hidden = true
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
        }
        
        return cell
    }
    
    // MARK: -
    
    private func dapps() -> [PFObject]? {
        let index = self.dappsFilterSegmentedControl.selectedSegmentIndex
        
        if index == DappsFilter.DappSigns.rawValue {
            return self.dappsCreatedByUserInProfile
        } else if index == DappsFilter.Dapped.rawValue {
            return self.dappsSwipedByUserInProfile
        }
        
        return nil
    }
    
    private func canShowDappButtonInCellWithDappWithId(dappId: String) -> Bool {
        if self.user.objectId == PFUser.currentUser().objectId {
            return false
        }
        
        if let dappsIdsSwipedByLoggedInUser = self.dappsIdsSwipedByLoggedInUser {
            if dappsIdsSwipedByLoggedInUser.contains(dappId) {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Requests
    
    private func downloadDapps() {
        let index = self.dappsFilterSegmentedControl.selectedSegmentIndex
        
        if index == DappsFilter.DappSigns.rawValue {
            self.downloadDappsCreatedByUser()
        } else if index == DappsFilter.Dapped.rawValue {
            self.downloadDappsSwipedByUser()
        }
    }
    
    private func downloadDappsCreatedByUser() {
        Requests.downloadDappsCreatedByUserWithId(self.user.objectId, completion: {
            (dapps: [PFObject], error: NSError!) -> Void in
            if error != nil {
                let alertView = UIAlertView(
                    title: "Error",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK"
                )
                
                alertView.show()
                
                return
            }
            
            self.dappsCreatedByUserInProfile = dapps
            
            self.tableView.reloadData()
        })
    }
    
    private func downloadDappsSwipedByUser() {
        Requests.downloadDappsSwipedByUser(self.user, completion: {
            (dapps: [PFObject], error: NSError!) -> Void in
            if error != nil {
                let alertView = UIAlertView(
                    title: "Error",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK"
                )
                
                alertView.show()
                
                return
            }
            
            self.dappsSwipedByUserInProfile = dapps
            
            self.tableView.reloadData()
        })
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
            } else {
                if let error = error {
                    message = "Failed to dapp this card. Error: \(error.localizedDescription)"
                } else {
                    message = "Failed to dapp this card. Unknown error."
                }
            }
            
            let alertView = UIAlertView(
                title: nil,
                message: message,
                delegate: nil,
                cancelButtonTitle: "OK"
            )
            
            alertView.show()
            
            completion(succeeded: succeeded)
        })
    }
}

extension ProfileViewController: SWTableViewCellDelegate {
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if let dapps = self.dapps() {
                let dapp = dapps[indexPath.row];
                
                self.dapp(dapp, completion: {
                    (succeeded: Bool) -> Void in
                    if succeeded {
                        self.incrementDappScores(dapp)
                    }
                    
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                })
                
                cell.hideUtilityButtonsAnimated(true)
            }
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

extension ProfileViewController: DappProfileCellDelegate {
    func editLinkInCell(cell: DappProfileCell) {
        if let indexPath = self.tableView.indexPathForCell(cell), dapps = self.dapps() {
            if indexPath.row < dapps.count {
                self.selectedDappSegue = dapps[indexPath.row]
                
                self.performSegueWithIdentifier(self.editLinksSegueID, sender: self)
            }
        }
    }
}
