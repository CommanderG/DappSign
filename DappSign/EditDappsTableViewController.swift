//
//  EditDappsTableViewController.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/13/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class EditDappsTableViewController: UITableViewController {
    var dappsCount: [DappType: Int32] = [
        .Primary: -1,
        .Secondary: -1,
        .Unapproved: -1
    ]
    
    enum SegueIdentifier: String {
        case ShowPrimaryDapps = "showPrimaryDappsTableViewController"
        case ShowSecondaryDapps = "showSecondaryDappsTableViewController"
        case ShowUnapprovedDapps = "showUnapprovedDappsTableViewController"
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
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        let dappType = DappType(rawValue: indexPath.row)
        
        self.showDappCountInCell(cell, dappType: dappType)
        
        return cell
    }
    
    // MARK: - @IBActions
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.ShowPrimaryDapps.rawValue {
            return self.shouldPerformSegueToShowDappsWithType(DappType.Primary)
        } else if identifier == SegueIdentifier.ShowSecondaryDapps.rawValue {
            return self.shouldPerformSegueToShowDappsWithType(DappType.Secondary)
        } else if identifier == SegueIdentifier.ShowUnapprovedDapps.rawValue {
            return self.shouldPerformSegueToShowDappsWithType(DappType.Unapproved)
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowPrimaryDapps.rawValue {
            (segue.destinationViewController as DappsTableViewController).dappsType = .Primary
        } else if segue.identifier == SegueIdentifier.ShowSecondaryDapps.rawValue {
            (segue.destinationViewController as DappsTableViewController).dappsType = .Secondary
        } else if segue.identifier == SegueIdentifier.ShowUnapprovedDapps.rawValue {
            (segue.destinationViewController as DappsTableViewController).dappsType = .Unapproved
        }
    }
    
    // MARK: - 
    
    private func shouldPerformSegueToShowDappsWithType(dappType: DappType) -> Bool {
        let count = self.dappsCount[dappType]
        
        if count > 0 {
            return true
        }
        
        return false
    }
    
    private func showDappCountInCell(cell: UITableViewCell, dappType: DappType?) -> Void {
        if let dappType = dappType {
            if let count = self.dappsCount[dappType] {
                if count > 0 {
                    cell.detailTextLabel?.text = String(count)
                    
                    cell.accessoryType = .DisclosureIndicator
                    cell.selectionStyle = .Default
                } else {
                    if count == 0 {
                        cell.detailTextLabel?.text = "0"
                    } else {
                        cell.detailTextLabel?.text = nil
                    }
                    
                    cell.accessoryType = .None
                    cell.selectionStyle = .None
                }
                
                return
            }
        }
        
        cell.detailTextLabel?.text = nil
        
        cell.accessoryType = .None
        cell.selectionStyle = .None
    }
    
    private func refreshTableViewContent() -> Void {
        self.refreshTableViewContentForDappType(.Primary)
        self.refreshTableViewContentForDappType(.Secondary)
        self.refreshTableViewContentForDappType(.Unapproved)
    }
    
    private func refreshTableViewContentForDappType(dappType: DappType) -> Void {
        if let query = DappQueriesBuilder.queryForAllDappsOfType(dappType) {
            query.countObjectsInBackgroundWithBlock {
                (count: Int32, error: NSError!) -> Void in
                if error == nil {
                    self.dappsCount[dappType] = count
                    
                    let cellIndexPath = NSIndexPath(
                        forRow: dappType.rawValue,
                        inSection: 0
                    )
                    
                    self.tableView.reloadRowsAtIndexPaths([cellIndexPath],
                        withRowAnimation: .None
                    )
                }
            }
        }
    }
}
