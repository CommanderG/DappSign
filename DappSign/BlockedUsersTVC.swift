//
//  BlockedUsersTVC.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 9/11/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class BlockedUsersTVC: UITableViewController {
    private var users: [PFUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Blocked users"
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        BlockedUsersHelper.blockedUsers {
            (users: [PFUser]?) in
            if let users = users {
                self.users = users
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - <UITableViewDataSource>
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "cell",
            forIndexPath: indexPath
        )
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user["name"] as? String ?? ""
        
        return cell
    }
}
