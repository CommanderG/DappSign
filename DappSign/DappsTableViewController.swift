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
    var dappIndexes:          [DappIndex] = []
    var actionSheet:          UIActionSheet?
    var dappWithTheSameIndex: PFObject?
    var selectedDappNewIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if let dappsArray = self.dappsArray {
            if dappsArray != .Secondary {
                self.showEditButton()
            }
        }
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
            
            DappArraysHelper.downloadAllDappsInArray(dappsArray, completion: {
                (dapps: [PFObject]?, error: NSError?) -> Void in
                if let dapps = dapps {
                    if dappsArray == .Secondary {
                        DappsHelper.sortDappsByDappScore(dapps, completion: {
                            (sortedDapps: [PFObject]) -> Void in
                            self.dapps = sortedDapps
                            
                            self.tableView.reloadData()
                        })
                    } else {
                        let arrayName = dappsArray.rawValue
                        DappIndexHelper.downloadDappIndexesForArrayWithName(arrayName, completion: {
                            (dappIndexes: [DappIndex]?, error: NSError?) -> Void in
                            if let dappIndexes = dappIndexes {
                                self.dapps = DappsHelper.orderDappsByIndex(dapps,
                                    dappIndexes: dappIndexes,
                                    dappArray: dappsArray
                                )
                                self.dappIndexes = dappIndexes
                                
                                self.tableView.reloadData()
                            } else {
                                self.showFailedToDownloadDappsError(error, dappsArray: dappsArray)
                            }
                        })
                    }
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
        
        var newDappIndexes: [DappIndex] = []
        var newDappIndexObjects: [PFObject] = []
        
        for index in 0 ..< self.dapps.count {
            let dapp = self.dapps[index]
            let dappIndex = ArrayUtil.findElement({
                dappIndex -> Bool in
                return dappIndex.dappID == dapp.objectId
            }, inArray: self.dappIndexes)
            
            if let dappIndex = dappIndex {
                let newDappIndex = DappIndex(
                    parseObjectID: dappIndex.parseObjectID,
                    dappID: dappIndex.dappID,
                    dappsArrayName: dappIndex.dappsArrayName,
                    index: index
                )
                
                newDappIndexes.append(newDappIndex)
                
                let newDappIndexObject = PFObject(className: "DappIndex")
                
                newDappIndexObject.objectId = newDappIndex.parseObjectID
                newDappIndexObject["dappID"] = newDappIndex.dappID
                newDappIndexObject["dappsArrayName"] = newDappIndex.dappsArrayName
                newDappIndexObject["index"] = newDappIndex.index
                
                newDappIndexObjects.append(newDappIndexObject)
            }
        }
        
        self.navigationItem.leftBarButtonItem = nil
        self.tableView.userInteractionEnabled = false
        
        PFObject.saveAllInBackground(newDappIndexObjects) {
            (success: Bool, error: NSError?) -> Void in
            self.showEditButton()
            
            self.tableView.userInteractionEnabled = true
            
            if success {
                self.dappIndexes = newDappIndexes
            } else {
                if let dappsArray = self.dappsArray {
                    self.dapps = DappsHelper.orderDappsByIndex(self.dapps,
                        dappIndexes: self.dappIndexes,
                        dappArray: dappsArray
                    )
                    
                    self.tableView.reloadData()
                }
            }
        }
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
        let selectedDapp = self.dapps[selectedDappIndex]
        
        if let buttonTitle = actionSheet.buttonTitleAtIndex(buttonIndex), dappsArray = dappsArray {
            switch buttonTitle {
            case actionSheetButtonRemoveFromThisArray:
                self.removeDapp(selectedDapp,
                    fromArray: dappsArray,
                    dappIndex: selectedDappIndex,
                    success: nil
                )
            case actionSheetButtonMoveToPrimaryArray:
                self.moveDapp(selectedDapp,
                    withIndex: selectedDappIndex,
                    toArray: .Primary,
                    afterRemovingItFromArray: dappsArray
                )
            case actionSheetButtonMoveToSecondaryArray:
                self.moveDapp(selectedDapp,
                    withIndex: selectedDappIndex,
                    toArray: .Secondary,
                    afterRemovingItFromArray: dappsArray
                )
            case actionSheetButtonMoveToIntroductoryArray:
                self.moveDapp(selectedDapp,
                    withIndex: selectedDappIndex,
                    toArray: .Introductory,
                    afterRemovingItFromArray: dappsArray
                )
            case actionSheetButtonAddToScoreboardArray:
                self.checkIfDappWithID(selectedDapp.objectId,
                    existsInArray: .Scoreboard,
                    completion: {
                        (exists: Bool?, error: NSError?) -> Void in
                        if let exists = exists {
                            if exists {
                                self.showAlertViewWithOKButtonAndMessage(
                                    "This dapp has already been added to Scoreboard array."
                                )
                                
                                return
                            }
                            
                            DappTransferHelper.addDapp(selectedDapp,
                                toArray: .Scoreboard,
                                completion: {
                                    (error: NSError?) -> Void in
                                    if let error = error {
                                        self.showAlertViewWithOKButtonAndError(error)
                                    }
                            })
                        } else if let error = error {
                            self.showAlertViewWithOKButtonAndError(error)
                        }
                })
            default:
                break
            }
        }
    }
    
    private func removeDapp(dapp: PFObject,
        fromArray dappArray: DappArray,
        dappIndex: Int,
        success: (Void -> Void)?
    ) {
        DappTransferHelper.removeDapp(dapp, fromArray: dappArray, completion: {
            (error: NSError?) -> Void in
            if let error = error {
                self.showAlertViewWithOKButtonAndError(error)
                
                return
            }
            
            self.dapps.removeAtIndex(dappIndex)
            self.tableView.reloadData()
            
            if (dappArray == .Secondary) {
                success?()
                
                return
            }
            
            DappIndexHelper.updateDappIndexes(self.dappIndexes,
                byDeletingDappIndexForDeletedDapp: dapp,
                completion: {
                    (updatedDappIndexes: [DappIndex]?, error: NSError?) -> Void in
                    if let updatedDappIndexes = updatedDappIndexes {
                        self.dappIndexes = updatedDappIndexes
                        
                        success?()
                    } else if let error = error {
                        self.showAlertViewWithOKButtonAndError(error)
                    }
            })
        })
    }
    
    private func moveDapp(dapp: PFObject,
        withIndex dappIndex: Int,
        toArray dappArrayToAddTo: DappArray,
        afterRemovingItFromArray dappArrayToRemoveFrom: DappArray
    ) {
        let dappStatement = dapp["dappStatement"]
        print(" - moveDapp \(dappStatement)")
        
        self.removeDapp(dapp, fromArray: dappArrayToRemoveFrom, dappIndex: dappIndex, success: {
            DappTransferHelper.addDapp(dapp, toArray: dappArrayToAddTo, completion: {
                (error: NSError?) -> Void in
                if let error = error {
                    self.showAlertViewWithOKButtonAndError(error)
                }
            })
        })
    }
    
    private func showAlertViewWithOKButtonAndError(error: NSError) {
        self.showAlertViewWithOKButtonAndMessage("\(error.localizedDescription)")
    }
    
    private func checkIfDappWithID(dappID: String,
        existsInArray: DappArray,
        completion: (exists: Bool?, error: NSError?) -> Void
    ) {
        DappArraysHelper.downloadAllDappsInArray(.Scoreboard, completion: {
            (dapps: [PFObject]?, error: NSError?) -> Void in
            if let dapps = dapps {
                for dapp in dapps {
                    if dapp.objectId == dappID {
                        completion(exists: true, error: nil)
                        
                        return
                    }
                }
                
                completion(exists: false, error: nil)
            } else {
                completion(exists: nil, error: error)
            }
        })
    }
}
