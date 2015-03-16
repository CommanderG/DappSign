//
//  DappsTableViewController.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/13/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

enum UIActionSheetButton: String {
    case Delete = "Delete"
    case MakePrimary = "Make primary"
    case MakeSecondary = "Make secondary"
    case SetIndex = "Set index"
    case Cancel = "Cancel"
}

class DappsTableViewController: UITableViewController {
    var dappsType: DappType?
    let cellIdentifier = "cell"
    let dappStatementKey = "dappStatement"
    var dapps: [PFObject]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        
        // case .Primary
        //     ["set index", "make secondary", "delete"]
        // case .Secondary
        //     ["maked primary", "delete"]
        // case .Unapproved
        //     ["make primary", "make secondary", "delete"]
        
        /*
        let alertView = UIAlertView(
        title: "Set index",
        message: "",
        delegate: nil,
        cancelButtonTitle: "Cancel",
        otherButtonTitles: "OK"
        )
        alertView.alertViewStyle = .PlainTextInput
        
        if let textField = alertView.textFieldAtIndex(0) {
        textField.keyboardType = .NumberPad
        
        alertView.show()
        }
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dappsType = self.dappsType {
            switch dappsType {
                case .Primary:
                    self.title = "Primary Dapps"
                case .Secondary:
                    self.title = "Secondary Dapps"
                case .Unapproved:
                    self.title = "Unapproved Dapps"
            }
            
            if var query = DappQueriesBuilder.queryForAllDappsOfType(dappsType) {
                query.orderByAscending("createdAt")
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error != nil {
                        println(error)
                        
                        return
                    }
                    
                    var dapps = objects as [PFObject]
                    
                    if dappsType == .Secondary {
                        sort(&dapps, {
                            (dapp1: PFObject, dapp2: PFObject) -> Bool in
                            return dapp1["dappScore"] as? Int > dapp2["dappScore"] as? Int
                        })
                    }
                    
                    self.dapps = dapps
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    
    private func actionSheetWithTitle(title: String) -> UIActionSheet? {
        if let dappsType = self.dappsType {
            switch dappsType {
                case .Primary:
                    return UIActionSheet(
                        title: title,
                        delegate: self,
                        cancelButtonTitle: UIActionSheetButton.Cancel.rawValue,
                        destructiveButtonTitle: UIActionSheetButton.Delete.rawValue,
                        otherButtonTitles: UIActionSheetButton.MakeSecondary.rawValue, UIActionSheetButton.SetIndex.rawValue
                    )
            case .Secondary:
                return UIActionSheet(
                    title: title,
                    delegate: self,
                    cancelButtonTitle: UIActionSheetButton.Cancel.rawValue,
                    destructiveButtonTitle: UIActionSheetButton.Delete.rawValue,
                    otherButtonTitles: UIActionSheetButton.MakePrimary.rawValue
                )
            case .Unapproved:
                return UIActionSheet(
                    title: title,
                    delegate: self,
                    cancelButtonTitle: UIActionSheetButton.Cancel.rawValue,
                    destructiveButtonTitle: UIActionSheetButton.Delete.rawValue,
                    otherButtonTitles: UIActionSheetButton.MakePrimary.rawValue, UIActionSheetButton.MakeSecondary.rawValue
                )
            }
        }
        
        return nil
    }
}

extension DappsTableViewController: UITableViewDataSource {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dapps = self.dapps {
            return dapps.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier,
            forIndexPath: indexPath) as DappCardCell
        
        if let dapps = self.dapps {
            let dapp = dapps[indexPath.row] as PFObject
            
            cell.dappStatementLabel.text = dapp[self.dappStatementKey] as? String
        }
        
        return cell
    }
}

extension DappsTableViewController: UITableViewDelegate {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let dappStatement = self.dapps?[indexPath.row][self.dappStatementKey] as? String {
            if let actionSheet = self.actionSheetWithTitle(dappStatement) {
                actionSheet.tag = indexPath.row
                actionSheet.showInView(self.tableView)
            }
        }
    }
}

extension DappsTableViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let selectedDappIndex = actionSheet.tag
        let buttonTitle = actionSheet.buttonTitleAtIndex(buttonIndex)
        
        if buttonTitle == UIActionSheetButton.Delete.rawValue {
            self.updatePropertiesForDappAtIndex(selectedDappIndex,
                properties: ["isDeleted": true]
            )
        } else if buttonTitle == UIActionSheetButton.MakePrimary.rawValue {
            self.updatePropertiesForDappAtIndex(selectedDappIndex,
                properties: ["dappTypeId": DappTypeId.Primary.rawValue]
            )
        } else if buttonTitle == UIActionSheetButton.MakeSecondary.rawValue {
            self.updatePropertiesForDappAtIndex(selectedDappIndex,
                properties: ["dappTypeId": DappTypeId.Secondary.rawValue]
            )
        } else if buttonTitle == UIActionSheetButton.SetIndex.rawValue {
            UIAlertView(
                title: ":)",
                message: "In development.",
                delegate: nil,
                cancelButtonTitle: "OK"
            ).show()
        }
    }
    
    // MARK: -
    
    private func updatePropertiesForDappAtIndex(dappIndex: Int, properties: [String: AnyObject]) {
        if var dapp = self.dapps?[dappIndex] {
            for (key, value) in properties {
                dapp[key] = value
            }
            
            self.tableView.userInteractionEnabled = false
            
            dapp.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError!) -> Void in
                self.tableView.userInteractionEnabled = true
                
                if error != nil {
                    println(error)
                    
                    return
                }
                
                self.dapps?.removeAtIndex(dappIndex)
                
                let indexPath = NSIndexPath(
                    forRow: dappIndex,
                    inSection: 0
                )
                
                self.tableView.deleteRowsAtIndexPaths([indexPath],
                    withRowAnimation: .None
                )
            })
        }
    }
}
