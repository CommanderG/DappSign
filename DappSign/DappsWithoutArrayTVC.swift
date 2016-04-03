//
//  DappsWithoutArrayTVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/18/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappsWithoutArrayTVC: UITableViewController {
    private var dappsWithoutArray: [PFObject] = []
    private var selectedDapp:      PFObject? = nil
    private var actionSheet:       UIActionSheet? = nil
    
    private let actionSheetButtonCancel                  = "Cancel"
    private let actionSheetButtonMoveToPrimaryArray      = "Move to Primary array"
    private let actionSheetButtonMoveToSecondaryArray    = "Move to Secondary array"
    private let actionSheetButtonMoveToIntroductoryArray = "Move to Introductory array"
    private let actionSheetButtonMoveToScoreboardArray   = "Move to Scoreboard array"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "No Array Dapps"
        
        DappsWithoutArrayHelper.downloadDappsWithoutArray {
            (dappsWithoutArray: [PFObject]?, error: NSError?) -> Void in
            if let dappsWithoutArray = dappsWithoutArray {
                self.dappsWithoutArray = dappsWithoutArray
                
                self.tableView.reloadData()
            } else {
                print(error)
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
        return self.dappsWithoutArray.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let dapp = self.dappsWithoutArray[indexPath.row]
        
        cell.textLabel?.text = dapp["dappStatement"] as? String ?? ""
        
        return cell
    }
    
    // MARK: - <UITableViewDelegate>
    
    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath
    ) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedDapp = self.dappsWithoutArray[indexPath.row]
        
        let actionSheetTitle = self.selectedDapp?["dappStatement"] as? String
        
        self.actionSheet = UIActionSheet(
            title:                  actionSheetTitle,
            delegate:               self,
            cancelButtonTitle:      actionSheetButtonCancel,
            destructiveButtonTitle: nil,
            otherButtonTitles:      actionSheetButtonMoveToPrimaryArray,
                                    actionSheetButtonMoveToSecondaryArray,
                                    actionSheetButtonMoveToIntroductoryArray,
                                    actionSheetButtonMoveToScoreboardArray
        )
        
        self.actionSheet?.showInView(self.view)
    }
}

extension DappsWithoutArrayTVC: UIActionSheetDelegate {
    internal func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let
            selectedDapp = self.selectedDapp,
            buttonTitle = actionSheet.buttonTitleAtIndex(buttonIndex),
            dappArray = self.dappArrayFromButtonTitle(buttonTitle) {
                self.addDapp(selectedDapp, toArray: dappArray, success: {
                    if let selectedDappIndex = self.dappsWithoutArray.indexOf(selectedDapp) {
                        self.dappsWithoutArray.removeAtIndex(selectedDappIndex)
                        self.tableView.reloadData()
                    }
                    
                    self.addDappIndexForDapp(selectedDapp, dappArray: dappArray)
                })
        }
    }
    
    private func dappArrayFromButtonTitle(buttonTitle: String) -> DappArray? {
        var dappArray: DappArray? = nil
        
        switch buttonTitle {
        case actionSheetButtonMoveToPrimaryArray:
            dappArray = .Primary
        case actionSheetButtonMoveToSecondaryArray:
            dappArray = .Secondary
        case actionSheetButtonMoveToIntroductoryArray:
            dappArray = .Introductory
        case actionSheetButtonMoveToScoreboardArray:
            dappArray = .Scoreboard
        case _:
            dappArray = nil
        }
        
        return dappArray
    }
    
    private func addDapp(dapp: PFObject,
        toArray dappArray: DappArray,
        success: () -> Void
    ) {
        DappArraysHelper.addDapp(dapp, toArray: dappArray, completion: {
            (error: NSError?) -> Void in
            if let error = error {
                let errorMessage =
                "Failed to add dapp to \(dappArray.rawValue) array. " +
                "Error: \(error.localizedDescription)"
                
                self.showAlertViewWithOKButtonAndMessage(errorMessage)
            } else {
                success()
            }
        })
    }
    
    private func addDappIndexForDapp(dapp: PFObject, dappArray: DappArray) {
        DappIndexHelper.downloadDappIndexesForArrayWithName(dappArray.rawValue, completion: {
            (dappIndexes: [DappIndex]?, error: NSError?) -> Void in
            if let
                dappIndexes = dappIndexes,
                maxIndex = DappIndexHelper.maxIndexInDappIndexes(dappIndexes) {
                    let index = maxIndex + 1
                    let dappIndex = DappIndex(
                        parseObjectID:  "",
                        dappID:         dapp.objectId,
                        dappsArrayName: dappArray.rawValue,
                        index:          index
                    )
                    
                    DappIndexHelper.addDappIndex(dappIndex, completion: {
                        (error: NSError?) -> Void in
                    })
            }
        })
    }
}
