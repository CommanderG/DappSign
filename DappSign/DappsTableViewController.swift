//
//  DappsTableViewController.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 3/13/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

enum UIActionSheetButton: String {
    case Delete           = "Delete"
    case MakePrimary      = "Make primary"
    case MakeSecondary    = "Make secondary"
    case MakeIntroductory = "Make introductory"
    case SetIndex         = "Set index"
    case Cancel           = "Cancel"
}

enum UIAlertViewTag: Int {
    case IndexInput         = 0
    case IndexAlreadyExists = 1
}

enum UIAlertViewButtonTitles: String {
    case OKButton        = "OK"
    case CancelButton    = "Cancel"
    case OverwriteButton = "Overwrite"
}

class DappsTableViewController: UITableViewController {
    let cellIdentifier = "cell"
    let dappStatementKey = "dappStatement"
    
    var dappsType:            DappType?
    var dapps:                [PFObject] = []
    var actionSheet:          UIActionSheet?
    var dappWithTheSameIndex: PFObject?
    var selectedDappNewIndex: Int?
    var dappsDownloader:      DappsDownloader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dappsType = self.dappsType {
            switch dappsType {
            case .Primary:
                self.title = "Primary Dapps"
            case .Secondary:
                self.title = "Secondary Dapps"
            case .Introductory:
                self.title = "Introductory Dapps"
            }
            
            self.dappsDownloader = DappsDownloader(type: dappsType)
            
            self.dappsDownloader.downloadAllDapps({
                (dapps: [PFObject], error: NSError!) -> Void in
                if error != nil {
                    let alertView = UIAlertView(
                        title: nil,
                        message: error.localizedDescription,
                        delegate: nil,
                        cancelButtonTitle: "OK"
                    )
                    
                    alertView.show()
                    
                    return
                }
                
                self.dapps = dapps
                
                self.tableView.reloadData()
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
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dapps.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier,
            forIndexPath: indexPath) as! DappCardCell
        
        let dapp = dapps[indexPath.row] as PFObject
        
        cell.dappStatementLabel.text = dapp[self.dappStatementKey] as? String
        
        if let dappsType = self.dappsType {
            if dappsType == .Primary {
                if let index = dapp["index"] as? Int {
                    if index >= 0 {
                        cell.dappIndexLabel.text = String(index)
                    } else {
                        cell.dappIndexLabel.text = nil
                    }
                } else {
                    cell.dappIndexLabel.text = nil
                }
            }
        }
        
        if let dappsType = self.dappsType {
            if dappsType != .Primary {
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
    
    // MARK: -
    
    private func actionSheetWithTitle(title: String) -> UIActionSheet? {
        if let dappsType = self.dappsType {
            switch dappsType {
            case .Primary:
                return UIActionSheet(
                    title:                  title,
                    delegate:               self,
                    cancelButtonTitle:      UIActionSheetButton.Cancel.rawValue,
                    destructiveButtonTitle: UIActionSheetButton.Delete.rawValue,
                    otherButtonTitles:      UIActionSheetButton.MakeSecondary.rawValue,
                                            UIActionSheetButton.MakeIntroductory.rawValue,
                                            UIActionSheetButton.SetIndex.rawValue
                )
            case .Secondary:
                return UIActionSheet(
                    title:                  title,
                    delegate:               self,
                    cancelButtonTitle:      UIActionSheetButton.Cancel.rawValue,
                    destructiveButtonTitle: UIActionSheetButton.Delete.rawValue,
                    otherButtonTitles:      UIActionSheetButton.MakePrimary.rawValue,
                                            UIActionSheetButton.MakeIntroductory.rawValue
                )
            case .Introductory:
                return UIActionSheet(
                    title:                  title,
                    delegate:               self,
                    cancelButtonTitle:      UIActionSheetButton.Cancel.rawValue,
                    destructiveButtonTitle: UIActionSheetButton.Delete.rawValue,
                    otherButtonTitles:      UIActionSheetButton.MakePrimary.rawValue,
                                            UIActionSheetButton.MakeSecondary.rawValue
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
            case UIActionSheetButton.Delete.rawValue:
                self.updatePropertiesForDappAtIndex(selectedDappIndex,
                    properties: ["isDeleted": true]
                )
            case UIActionSheetButton.MakePrimary.rawValue:
                let query = DappQueriesBuilder.queryForAllDappsOfType(.Primary)
                
                query?.countObjectsInBackgroundWithBlock({
                    (count: Int32, error: NSError!) -> Void in
                    if Int(count) == primaryDappsMaxCount {
                        let message =
                        "Can't make this Dapp primary because maximum number " +
                        "of primary Dapps (\(primaryDappsMaxCount)) has been reached."
                        
                        let alertView = UIAlertView(
                            title:             "Error",
                            message:           message,
                            delegate:          nil,
                            cancelButtonTitle: "OK"
                        )
                        
                        alertView.show()
                        
                        return
                    }
                    
                    self.updatePropertiesForDappAtIndex(selectedDappIndex,
                        properties: ["dappTypeId": DappTypeId.Primary.rawValue]
                    )
                })
            case UIActionSheetButton.MakeSecondary.rawValue:
                self.updatePropertiesForDappAtIndex(selectedDappIndex,
                    properties: ["dappTypeId": DappTypeId.Secondary.rawValue]
                )
            case UIActionSheetButton.MakeIntroductory.rawValue:
                self.updatePropertiesForDappAtIndex(selectedDappIndex,
                    properties: ["dappTypeId": DappTypeId.Introductory.rawValue]
                )
            case UIActionSheetButton.SetIndex.rawValue:
                let message = "Index must be in range from 0 to \(primaryDappsMaxCount - 1)"
                let alertView = UIAlertView(
                    title:             "Set index",
                    message:           message,
                    delegate:          self,
                    cancelButtonTitle: UIAlertViewButtonTitles.CancelButton.rawValue,
                    otherButtonTitles: UIAlertViewButtonTitles.OKButton.rawValue
                )
                
                alertView.alertViewStyle = .PlainTextInput
                alertView.tag = UIAlertViewTag.IndexInput.rawValue
                
                if let textField = alertView.textFieldAtIndex(0) {
                    textField.keyboardType = .NumberPad
                    textField.delegate = self
                    
                    alertView.show()
                }
            default:
                break
            }
        }
    }
}

extension DappsTableViewController: UIAlertViewDelegate {
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let buttonTitle = alertView.buttonTitleAtIndex(buttonIndex)
        
        if alertView.tag == UIAlertViewTag.IndexInput.rawValue {
            if buttonTitle != UIAlertViewButtonTitles.OKButton.rawValue {
                return
            }
            
            if let text = alertView.textFieldAtIndex(0)?.text, newIndex = Int(text) {
                self.selectedDappNewIndex = newIndex
                self.dappWithTheSameIndex = self.dappWithIndex(newIndex)
                
                if self.dappWithTheSameIndex == nil {
                    if let selectedDappIndex = self.actionSheet?.tag {
                        let dapp = self.dapps[selectedDappIndex]
                        
                        self.tableView.userInteractionEnabled = false
                        
                        self.changeDappIndexTo(newIndex,
                            dappThatWillBeUpdated: dapp,
                            completion: {
                                (succeeded: Bool) -> Void in
                                if succeeded {
                                    self.tableView.userInteractionEnabled = true
                                    
                                    self.dapps = PrimaryDapps.sortDapps(self.dapps)
                                    
                                    self.tableView.reloadData()
                                }
                        })
                    }
                } else {
                    let message =
                    "Dapp with the same index already exists. " +
                    "Would you like to overwrite it's index?\n\n" +
                    "\(self.dappWithTheSameIndex![self.dappStatementKey])"
                    
                    let alertView = UIAlertView(
                        title:             "Warning",
                        message:           message,
                        delegate:          self,
                        cancelButtonTitle: UIAlertViewButtonTitles.CancelButton.rawValue,
                        otherButtonTitles: UIAlertViewButtonTitles.OverwriteButton.rawValue
                    )
                    
                    alertView.tag = UIAlertViewTag.IndexAlreadyExists.rawValue
                    
                    alertView.show()
                }
            }
        } else if alertView.tag == UIAlertViewTag.IndexAlreadyExists.rawValue {
            if buttonTitle != UIAlertViewButtonTitles.OverwriteButton.rawValue {
                return
            }
            
            if self.selectedDappNewIndex == nil {
                return
            }
            
            let selectedDappIndex = self.actionSheet?.tag
            
            if selectedDappIndex == nil {
                return
            }
            
            // here we set new index to the selected dapp, and if the request completes successfully,
            // app will send another request which will set index to -1 for the dapp which has the
            // same index as the new one. that way, since it's index will be < 0, it won't be sorted
            // by it's index, instead it will be sorted like any other dapp witout an index - by date
            // it was created
            let dapp = self.dapps[selectedDappIndex!]
            
            self.tableView.userInteractionEnabled = false
            
            self.changeDappIndexTo(self.selectedDappNewIndex!,
                dappThatWillBeUpdated: dapp,
                completion: {
                    (succeeded: Bool) -> Void in
                    if !succeeded {
                        self.tableView.userInteractionEnabled = true
                        
                        return
                    }
                    
                    if let dappWithTheSameIndex = self.dappWithTheSameIndex {
                        self.changeDappIndexTo(-1,
                            dappThatWillBeUpdated: dappWithTheSameIndex,
                            completion: {
                                (succeeded: Bool) -> Void in
                                self.tableView.userInteractionEnabled = true
                                
                                self.dapps = PrimaryDapps.sortDapps(self.dapps)
                                
                                self.tableView.reloadData()
                        })
                    }
            })
        }
    }
}

extension DappsTableViewController: UITextFieldDelegate {
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        if let currentText = textField.text as NSString? {
            let newText = currentText.stringByReplacingCharactersInRange(range, withString: string)
            
            if newText.characters.count == 0 {
                return true
            }
            
            if let index = Int(newText) {
                if index >= 0 && index < primaryDappsMaxCount {
                    return true
                }
            }
        }
        
        return false
    }
}
