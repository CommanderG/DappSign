//
//  DappsTableViewController.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/13/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappsTableViewController: UITableViewController {
    let actionSheetButtonRemoveFromThisArray     = "Remove from this array"
    let actionSheetButtonMoveToPrimaryArray      = "Move to Primary array"
    let actionSheetButtonMoveToSecondaryArray    = "Move to Secondary array"
    let actionSheetButtonMoveToIntroductoryArray = "Move to Introductory array"
    let actionSheetButtonAddToScoreboardArray    = "Add to Scoreboard array"
    let actionSheetButtonCancel                  = "Cancel"
    
    let dappStatementKey = "dappStatement"
    
    var dappsArray:           DappArray?
    var dapps:                [PFObject] = []
    var actionSheet:          UIActionSheet?
    var dappWithTheSameIndex: PFObject?
    var selectedDappNewIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.showEditButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dappsArray = self.dappsArray {
            switch dappsArray {
            case .Primary:
                self.title = "Primary Dapps"
            case .Secondary:
                self.title = "Secondary Dapps"
            case .Introductory:
                self.title = "Introductory Dapps"
            case .Scoreboard:
                self.title = "Scoreboard Dapps"
            }
            
            DappArraysHelper.downloadDappsInArray(dappsArray, completion: {
                (dapps: [PFObject]?, error: NSError?) -> Void in
                if let dapps = dapps {
                    let arrayName = dappsArray.rawValue
                    DappIndexHelper.downloadDappIndexesForArrayWithName(arrayName, completion: {
                        (dappIndexes: [DappIndex]?, error: NSError?) -> Void in
                        if let dappIndexes = dappIndexes {
                            self.dapps = DappsHelper.orderDappsByIndex(dapps,
                                dappIndexes: dappIndexes,
                                dappArray: dappsArray
                            )
                            
                            self.tableView.reloadData()
                        } else {
                            self.showFailedToDownloadDappsError(error, dappsArray: dappsArray)
                        }
                    })
                } else {
                    self.showFailedToDownloadDappsError(error, dappsArray: dappsArray)
                }
            })
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
    
    private func showFailedToDownloadDappsError(error: NSError?, dappsArray: DappArray) {
        var errorMessage = ""
        
        if let error = error {
            errorMessage = "Error: \(error.localizedDescription)"
        } else {
            errorMessage = "Unknown error"
        }
        
        let alertView = UIAlertView(
            title:             "Failed to download \(dappsArray.rawValue) dapps",
            message:           errorMessage,
            delegate:          nil,
            cancelButtonTitle: "OK"
        )
        
        alertView.show()
    }
    
    // MARK: - Navigation bar
    
    private func showEditButton() {
        let selector = Selector("enablePositionsEditing:")
        let editBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Edit,
            target: self,
            action: selector
        )
        
        self.navigationItem.rightBarButtonItem = editBarButtonItem
    }
    
    private func showSaveButton() {
        let selector = Selector("savePositions:")
        let saveBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Save,
            target: self,
            action: selector
        )
        
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    // MARK: - Navigation bar button item actions
    
    internal func enablePositionsEditing(sender: AnyObject) {
        self.tableView.setEditing(true, animated: true)
        
        self.showSaveButton()
    }
    
    internal func savePositions(sender: AnyObject) {
        self.tableView.setEditing(false, animated: true)
        
        self.showEditButton()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dapps.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cellIdentifier = "cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,
            forIndexPath: indexPath) as! DappCardCell
        
        let dapp = dapps[indexPath.row] as PFObject
        
        cell.dappStatementLabel.text = dapp[self.dappStatementKey] as? String
        
        if let dappsType = self.dappsArray {
            if dappsType != .Secondary {
                if let index = dapp["index"] as? Int {
                    if index >= 0 {
                        cell.dappIndexLabel.text = String(index)
                    } else {
                        cell.dappIndexLabel.text = ""
                    }
                } else {
                    cell.dappIndexLabel.text = ""
                }
                
                cell.dappIndexLabel.hidden = false
            } else {
                cell.dappIndexLabel.hidden = true
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let dappStatement = self.dapps[indexPath.row][self.dappStatementKey] as? String {
            actionSheet = self.actionSheetWithTitle(dappStatement)
            actionSheet?.tag = indexPath.row
            actionSheet?.showInView(self.tableView)
        }
    }
    
    override func tableView(tableView: UITableView,
        canMoveRowAtIndexPath indexPath: NSIndexPath
    ) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView,
        moveRowAtIndexPath sourceIndexPath: NSIndexPath,
        toIndexPath destinationIndexPath: NSIndexPath
    ) {
        let dapp = dapps[sourceIndexPath.row]
        
        dapps.removeAtIndex(sourceIndexPath.row)
        dapps.insert(dapp, atIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView,
        editingStyleForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCellEditingStyle {
        return .None
    }
    
    override func tableView(tableView: UITableView,
        shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath
    ) -> Bool {
        return false
    }
    
    // MARK: -
    
    private func actionSheetWithTitle(title: String) -> UIActionSheet? {
        if let dappsType = self.dappsArray {
            switch dappsType {
            case .Primary:
                return UIActionSheet(
                    title:                  title,
                    delegate:               self,
                    cancelButtonTitle:      actionSheetButtonCancel,
                    destructiveButtonTitle: actionSheetButtonRemoveFromThisArray,
                    otherButtonTitles:      actionSheetButtonMoveToSecondaryArray,
                                            actionSheetButtonMoveToIntroductoryArray,
                                            actionSheetButtonAddToScoreboardArray
                )
            case .Secondary:
                return UIActionSheet(
                    title:                  title,
                    delegate:               self,
                    cancelButtonTitle:      actionSheetButtonCancel,
                    destructiveButtonTitle: actionSheetButtonRemoveFromThisArray,
                    otherButtonTitles:      actionSheetButtonMoveToPrimaryArray,
                                            actionSheetButtonMoveToIntroductoryArray,
                                            actionSheetButtonAddToScoreboardArray
                )
            case .Introductory:
                return UIActionSheet(
                    title:                  title,
                    delegate:               self,
                    cancelButtonTitle:      actionSheetButtonCancel,
                    destructiveButtonTitle: actionSheetButtonRemoveFromThisArray,
                    otherButtonTitles:      actionSheetButtonMoveToPrimaryArray,
                                            actionSheetButtonMoveToSecondaryArray,
                                            actionSheetButtonAddToScoreboardArray
                )
            case .Scoreboard:
                return UIActionSheet(
                    title:                  title,
                    delegate:               self,
                    cancelButtonTitle:      actionSheetButtonCancel,
                    destructiveButtonTitle: actionSheetButtonRemoveFromThisArray
                )
            }
        }
        
        return nil
    }
    
    private func updatePropertiesForDappAtIndex(dappIndex: Int, properties: [String: AnyObject]) {
        let dapp = self.dapps[dappIndex]
        
        for (key, value) in properties {
            dapp[key] = value
        }
        
        self.tableView.userInteractionEnabled = false
        
        dapp.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError!) -> Void in
            self.tableView.userInteractionEnabled = true
            
            if error != nil {
                print(error)
                
                return
            }
            
            self.dapps.removeAtIndex(dappIndex)
            
            let indexPath = NSIndexPath(
                forRow: dappIndex,
                inSection: 0
            )
            
            self.tableView.deleteRowsAtIndexPaths([indexPath],
                withRowAnimation: .None
            )
        })
    }
    
    private func changeDappIndexTo(dappIndex: Int,
                                   dappThatWillBeUpdated dapp: PFObject,
                                   completion: (succeeded: Bool) -> Void) -> Void {
        dapp["index"] = dappIndex
        
        dapp.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError!) -> Void in
            completion(succeeded: true)
            
            if error != nil {
                print(error)
                
                return
            }
            
            if let dappIndexInArray = self.dapps.indexOf(dapp) {
                self.dapps[dappIndexInArray] = dapp
            }
        })
    }
    
    private func dappWithIndex(dappIndex: Int) -> PFObject? {
        for dapp in dapps {
            if let index = dapp["index"] as? Int {
                if index == dappIndex {
                    return dapp
                }
            }
        }
        
        return nil
    }
}

extension DappsTableViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let selectedDappIndex = actionSheet.tag
        
        if let buttonTitle = actionSheet.buttonTitleAtIndex(buttonIndex) {
            switch buttonTitle {
            case actionSheetButtonRemoveFromThisArray:
                break
            case actionSheetButtonMoveToPrimaryArray:
//                let query = DappQueriesBuilder.queryForAllDappsOfType(.Primary)
//                
//                query?.countObjectsInBackgroundWithBlock({
//                    (count: Int32, error: NSError!) -> Void in
//                    if Int(count) == primaryDappsMaxCount {
//                        let message =
//                        "Can't make this Dapp primary because maximum number " +
//                        "of primary Dapps (\(primaryDappsMaxCount)) has been reached."
//                        
//                        let alertView = UIAlertView(
//                            title:             "Error",
//                            message:           message,
//                            delegate:          nil,
//                            cancelButtonTitle: "OK"
//                        )
//                        
//                        alertView.show()
//                        
//                        return
//                    }
//                    
//                    self.updatePropertiesForDappAtIndex(selectedDappIndex,
//                        properties: ["dappTypeId": DappTypeId.Primary.rawValue]
//                    )
//                })
                break
            case actionSheetButtonMoveToSecondaryArray:
                break
//                self.updatePropertiesForDappAtIndex(selectedDappIndex,
//                    properties: [
//                        "index": -1,
//                        "dappTypeId": DappTypeId.Secondary.rawValue
//                    ]
//                )
            case actionSheetButtonMoveToIntroductoryArray:
                break
//                self.updatePropertiesForDappAtIndex(selectedDappIndex,
//                    properties: [
//                        "index": -1,
//                        "dappTypeId": DappTypeId.Introductory.rawValue
//                    ]
//                )
            default:
                break
            }
        }
    }
}
