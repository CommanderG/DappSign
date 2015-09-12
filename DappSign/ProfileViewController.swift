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
                    println(error)
                    
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
                if !contains(adminUsersIDs, currentUser.objectId) || self.user.objectId != currentUser.objectId {
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
    
    // MARK: - @IBActions
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dappsFilterSegmentedControlValueChanged(sender: AnyObject) {
        if let dapps = self.dapps() {
            self.tableView.reloadData()
        } else {
            self.downloadDapps()
        }
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
            if contains(dappsIdsSwipedByLoggedInUser, dappId) {
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

extension ProfileViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dapps = self.dapps() {
            return dapps.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! DappProfileCell
        
        if let dapps = self.dapps() {
            let dapp = dapps[indexPath.row]
            
            cell.dappSignView.showDapp(dapp)
            
            if let userID = dapp["userid"] as? String {
                Requests.userWithID(userID, completion: {
                    (user: PFUser?, error: NSError?) -> Void in
                    if let usr = user {
                        cell.dappSignView.showUserInfo(usr)
                    } else if let err = error {
                        println("Failed to download information about user with ID \(userID). Error = \(error)")
                    } else {
                        println("Failed to download information about user with ID \(userID). Unknown error.")
                    }
                })
            }
            
            if self.canShowDappButtonInCellWithDappWithId(dapp.objectId) {
                var buttons = NSMutableArray(capacity: 1)
                
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
                        if let userId = dapp["userid"] as? String {
                            Requests.incrementDappScoreForUserWithId(userId, completion: {
                                (succeeded: Bool, error: NSError?) -> Void in
                                if !succeeded {
                                    if let error = error {
                                        println(error.localizedDescription)
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
}
