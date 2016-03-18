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
    
    enum DappActionSheetButton: String {
        case Cancel                 = "Cancel"
        case AddToPrimaryArray      = "Add to Primary array"
        case AddToSecondaryArray    = "Add to Secondary array"
        case AddToIntroductoryArray = "Add to Introductory array"
        case AddToScoreboardArray   = "Add to Scoreboard array"
    }
    
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
            cancelButtonTitle:      DappActionSheetButton.Cancel.rawValue,
            destructiveButtonTitle: nil,
            otherButtonTitles:      DappActionSheetButton.AddToPrimaryArray.rawValue,
                                    DappActionSheetButton.AddToSecondaryArray.rawValue,
                                    DappActionSheetButton.AddToIntroductoryArray.rawValue,
                                    DappActionSheetButton.AddToScoreboardArray.rawValue
        )
        
        self.actionSheet?.showInView(self.view)
    }
}

extension DappsWithoutArrayTVC: UIActionSheetDelegate {
    internal func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let
            selectedDapp = self.selectedDapp,
            buttonTitle = actionSheet.buttonTitleAtIndex(buttonIndex),
            button = DappActionSheetButton(rawValue: buttonTitle) {
                var dappArray: DappArray? = nil
                
                switch button {
                case .Cancel:
                    break
                case .AddToPrimaryArray:
                    dappArray = .Primary
                case .AddToSecondaryArray:
                    dappArray = .Secondary
                case .AddToIntroductoryArray:
                    dappArray = .Introductory
                case .AddToScoreboardArray:
                    dappArray = .Scoreboard
                }
                
                if let dappArray = dappArray {
                    DappArraysHelper.addDapp(selectedDapp, toArray: dappArray, completion: {
                        (error: NSError?) -> Void in
                        if let error = error {
                            let errorMessage =
                            "Failed to add dapp to \(dappArray.rawValue) array. " +
                            "Error: \(error.localizedDescription)"
                            
                            self.showAlertViewWithOKButtonAndMessage(errorMessage)
                        } else if let
                            selectedDappIndex = self.dappsWithoutArray.indexOf(selectedDapp) {
                                self.dappsWithoutArray.removeAtIndex(selectedDappIndex)
                                self.tableView.reloadData()
                        }
                    })
                }
        }
    }
}
