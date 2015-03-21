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
    
    //design
    var dappColors = DappColors()
    var dappFonts = DappFonts()
    
    var dapps: [PFObject] = []
    
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
        
        self.downloadDappsCreatedByUser()
        
        profilePic.image = UIImage(data: user["image"] as NSData)
        nameLabel.text = user["name"] as? String
        
        let mainBundle = NSBundle.mainBundle()
        
        if let adminUsersIDs = mainBundle.objectForInfoDictionaryKey("AdminUsersIDs") as? [String] {
            if !contains(adminUsersIDs, self.user.objectId) {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - <UITableViewDataSource>
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dapps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as DappProfileCell
        
        let dapp = self.dapps[indexPath.row]
        
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
        
        return cell
    }
    
    // MARK: - Requests
    
    func downloadDappsCreatedByUser() {
        var query = PFQuery(className: "Dapps")
        
        query.whereKey("userid", equalTo: self.user.objectId)
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                println(error)
                
                return
            }
            
            self.dapps = objects as [PFObject]
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - @IBActions
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
