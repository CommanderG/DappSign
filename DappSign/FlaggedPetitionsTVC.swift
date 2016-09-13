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
    
    // MARK: - <UITableViewDelegate>
    
    override func tableView(
        tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath
    ) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let actionSheet = UIActionSheet(
            title: nil,
            delegate: self,
            cancelButtonTitle: "Cancel",
            destructiveButtonTitle: "Remove petition"
        )
        
        actionSheet.tag = indexPath.row
        
        actionSheet.showInView(self.view)
    }
}

extension FlaggedPetitionsTVC: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 /* Remove petition */ {
            let dapp = self.petitions[actionSheet.tag]
            
            DappArraysHelper.dappArrayForDappWithId(dapp.objectId, completion: {
                (dappArray: DappArray?) in
                guard let dappArray = dappArray else {
                    self.petitions.removeAtIndex(actionSheet.tag)
                    self.tableView.reloadData()
                    
                    return
                }
                
                DappArraysHelper.removeDappWithID(
                    dapp.objectId,
                    fromArray: dappArray,
                    completion: {
                        (error: NSError?) in
                        if let error = error {
                            print(error)
                            
                            return
                        }
                        
                        FlaggedPetitionsHelper.deleteObjectWithDappId(dapp.objectId,
                            completion: {
                                (error: NSError?) in
                                if let error = error {
                                    print(error)
                                } else {
                                    self.petitions.removeAtIndex(actionSheet.tag)
                                    self.tableView.reloadData()
                                }
                        })
                    }
                )
            })
        }
    }
}
