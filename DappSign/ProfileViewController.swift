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
        
        profilePic.image = UIImage(data: user["image"] as NSData)
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
    
    // MARK: - <UITableViewDataSource>
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dapps = self.dapps() {
            return dapps.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as DappProfileCell
        
        if let dapps = self.dapps() {
            let dapp = dapps[indexPath.row]
            
            if let dappBackgroundColorString = dapp["dappBackgroundColor"] as? String {
                cell.backgroundColor = dappColors.dappColorWheel[dappBackgroundColorString]
            }
            
            cell.dappStatementTextView.text = dapp["dappStatement"] as? String
            
            if let dappFontString = dapp["dappFont"] as? String {
                cell.dappStatementTextView.font = dappFonts.dappFontBook[dappFontString]
            }
            
            if let dappScore = dapp["dappScore"] as? Int {
                cell.dappScoreLabel.text = String(dappScore)
            } else {
                cell.dappScoreLabel.text = nil
            }
            
            cell.dappScoreLabel.textColor = UIColor.whiteColor()
            cell.dappStatementTextView.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - <UITableViewDelegate>
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if self.user.objectId == PFUser.currentUser().objectId {
            return []
        }
        
        var selecteedDappHasBeenDapped: Bool
        
        if self.user.objectId == PFUser.currentUser().objectId {
            selecteedDappHasBeenDapped = true
        } else {
            if let dapps = self.dapps() {
                let dapp = dapps[indexPath.row]
                
                if let dappsIdsSwipedByLoggedInUser = self.dappsIdsSwipedByLoggedInUser {
                    if contains(dappsIdsSwipedByLoggedInUser, dapp.objectId) {
                        selecteedDappHasBeenDapped = true
                    } else {
                        selecteedDappHasBeenDapped = false
                    }
                } else {
                    selecteedDappHasBeenDapped = false
                }
            } else {
                selecteedDappHasBeenDapped = false
            }
        }
        
        var dappAction: UITableViewRowAction
        
        if selecteedDappHasBeenDapped {
            dappAction = UITableViewRowAction(
                style: UITableViewRowActionStyle.Normal,
                title: "Dapp",
                handler: {
                    (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                    let alertView = UIAlertView(
                        title: nil,
                        message: "You have already tapped this dapp",
                        delegate: nil,
                        cancelButtonTitle: "OK"
                    )
                    
                    alertView.show()
            })
        } else {
            dappAction = UITableViewRowAction(
                style: UITableViewRowActionStyle.Default,
                title: "Dapp",
                handler: {
                    (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                    self.dappCardWithIndex(indexPath.row)
                    
                    self.tableView.setEditing(false, animated: true)
            })
        }
        
        return [dappAction]
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
    
    private func dappCardWithIndex(index: Int) {
        let dapps = self.dapps()
        
        if dapps == nil {
            return
        }
        
        let dapp = dapps![index]
        let currentUser = PFUser.currentUser()
        
        Requests.addDappToDappsSwipedArray(dapp, user: currentUser, completion: {
            (succeeded: Bool, error: NSError?) -> Void in
            var message: String
            
            if succeeded {
                message = "You have successfully dapped this card."
                
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
        })
    }
}
