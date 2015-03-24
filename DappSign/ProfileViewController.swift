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
    
    var dappsCreatedByUser: [PFObject]? = nil
    var dappsSwipedByUser: [PFObject]? = nil
    
    enum DappsFilter: Int {
        case DappSigns = 0
        case Dapped = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                if !contains(adminUsersIDs, currentUser.objectId) {
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
            
            cell.dappStatementLabel.text = dapp["dappStatement"] as? String
            
            if let dappFontString = dapp["dappFont"] as? String {
                cell.dappStatementLabel.font = dappFonts.dappFontBook[dappFontString]
            }
            
            if let dappScore = dapp["dappScore"] as? Int {
                cell.dappScoreLabel.text = String(dappScore)
            } else {
                cell.dappScoreLabel.text = nil
            }
            
            cell.dappScoreLabel.textColor = UIColor.whiteColor()
            cell.dappStatementLabel.textColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    // MARK: - <UITableViewDelegate>
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            return self.dappsCreatedByUser
        } else if index == DappsFilter.Dapped.rawValue {
            return self.dappsSwipedByUser
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
            
            self.dappsCreatedByUser = dapps
            
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
            
            self.dappsSwipedByUser = dapps
            
            self.tableView.reloadData()
        })
    }
}
