//
//  FlaggedPetitionsTVC.swift
//  DailyDapp
//
//  Created by Oleksiy Kovtun on 9/11/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class FlaggedPetitionsTVC: UITableViewController {
    private var petitions: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Flagged dapps"
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        FlaggedPetitionsHelper.flaggedPetitions {
            (petitions: [PFObject]?) in
            if let petitions = petitions {
                self.petitions = petitions
                
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
        return self.petitions.count
    }
    
    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "cell",
            forIndexPath: indexPath
        )
        
        let petition = self.petitions[indexPath.row]
        
        cell.textLabel?.text = petition["dappStatement"] as? String ?? ""
        
        return cell
    }
}
