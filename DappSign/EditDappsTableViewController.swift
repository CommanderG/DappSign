//
//  EditDappsTableViewController.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/13/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class EditDappsTableViewController: UITableViewController {
    var dappsCount: [DappType: Int32?] = [
        .Primary:      nil,
        .Secondary:    nil,
        .Introductory: nil
    ]
    
    enum SegueIdentifier: String {
        case ShowPrimaryDapps      = "showPrimaryDappsTableViewController"
        case ShowSecondaryDapps    = "showSecondaryDappsTableViewController"
        case ShowIntroductoryDapps = "showIntroductoryDappsTableViewController"
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
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for key in self.dappsCount.keys {
            self.dappsCount[key] = nil
        }
        
        self.refreshTableViewContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - <UITableViewDataSource>
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return super.numberOfSectionsInTableView(tableView)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        let dappType = DappType(rawValue: indexPath.row)
        
        self.showDappCountInCell(cell, dappType: dappType)
        
        return cell
    }
        
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case SegueIdentifier.ShowPrimaryDapps.rawValue:
            return self.shouldPerformSegueToShowDappsWithType(.Primary)
        case SegueIdentifier.ShowSecondaryDapps.rawValue:
            return self.shouldPerformSegueToShowDappsWithType(.Secondary)
        case SegueIdentifier.ShowIntroductoryDapps.rawValue:
            return self.shouldPerformSegueToShowDappsWithType(.Introductory)
        default:
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            var dappsType: DappType?
            
            switch segueIdentifier {
            case SegueIdentifier.ShowPrimaryDapps.rawValue:
                dappsType = .Primary
            case SegueIdentifier.ShowSecondaryDapps.rawValue:
                dappsType = .Secondary
            case SegueIdentifier.ShowIntroductoryDapps.rawValue:
                dappsType = .Introductory
            default:
                break
            }
            
            if let dappsType = dappsType {
                let dappsTVC = segue.destinationViewController as! DappsTableViewController
                
                dappsTVC.dappsType = dappsType
            }
        }
    }
    
    // MARK: - 
    
    private func shouldPerformSegueToShowDappsWithType(dappType: DappType) -> Bool {
        if let count = self.dappsCount[dappType] {
            if count > 0 {
                return true
            }
        }
        
        return false
    }
    
    private func showDappCountInCell(cell: UITableViewCell, dappType: DappType?) -> Void {
        if let
            dappType = dappType,
            dappTypeCount = self.dappsCount[dappType],
            count = dappTypeCount {
                if count > 0 {
                    cell.detailTextLabel?.text = String(count)
                } else if count == 0 {
                    cell.detailTextLabel?.text = "0"
                } else if count < 0 {
                    cell.detailTextLabel?.text = "-"
                }
                
                if count > 0 {
                    cell.accessoryType = .DisclosureIndicator
                    cell.selectionStyle = .Default
                } else {
                    cell.accessoryType = .None
                    cell.selectionStyle = .None
                }
        } else {
            cell.detailTextLabel?.text = "-"
            cell.accessoryType = .None
            cell.selectionStyle = .None
        }
    }
    
    private func refreshTableViewContent() -> Void {
        self.tableView.reloadData()
        
        self.refreshTableViewContentForDappType(.Primary)
        self.refreshTableViewContentForDappType(.Secondary)
        self.refreshTableViewContentForDappType(.Introductory)
    }
    
    private func refreshTableViewContentForDappType(dappType: DappType) -> Void {
        if let query = DappQueriesBuilder.queryForAllDappsOfType(dappType) {
            query.countObjectsInBackgroundWithBlock {
                (count: Int32, error: NSError!) -> Void in
                if error == nil {
                    self.dappsCount[dappType] = count
                    
                    let cellIndexPath = NSIndexPath(forRow: dappType.rawValue, inSection: 0)
                    
                    self.tableView.reloadRowsAtIndexPaths([cellIndexPath],
                        withRowAnimation: .None
                    )
                }
            }
        }
    }
}
