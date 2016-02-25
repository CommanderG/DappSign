//
//  DappLinksVCNew.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappLinksVCNew: UIViewController {
    @IBOutlet weak var linksTableView: UITableView!
    
    private var linkCellsInfo: [LinkCellInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
        
        self.linksTableView.estimatedRowHeight = 100.0
        self.linksTableView.rowHeight = UITableViewAutomaticDimension
        
        for row in 0 ... 3 {
            let linkCellInfo = LinkCellInfo(row: row, link: nil, type: .AddLink)
            
            self.linkCellsInfo.append(linkCellInfo)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DappLinksVCNew: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.linkCellsInfo.count
    }
    
    func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let linkCellInfoWithCurrentRow = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
            linkCellsInfo: self.linkCellsInfo
        )
        
        if let linkCellInfo = linkCellInfoWithCurrentRow {
            print(indexPath.row, linkCellInfo)
            
            let cellID = self.cellIDForLinkCellInfo(linkCellInfo)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
            let linkIndex = indexPath.row + 1
            
            if let addLinkCell = cell as? AddLinkCell {
                addLinkCell.delegate = self
                addLinkCell.linkIndexLabel.text = "\(linkIndex)"
            } else if let enterLinkCell = cell as? EnterLinkCell {
                enterLinkCell.delegate = self
            } else if let linkCell = cell as? LinkCell {
                linkCell.linkIndexLabel.text = "\(linkIndex)"
                linkCell.linkTitleLabel.text = linkCellInfo.link?.title
            } else if let deleteLinkcell = cell as? DeleteLinkCell {
                deleteLinkcell.delegate = self
            }
            
            return cell
        } else {
            print(indexPath.row, "???")
            
            let cell = tableView.dequeueReusableCellWithIdentifier("noLinkCell",
                forIndexPath: indexPath
            )
            
            return cell
        }
    }
    
    // MARK: - private
    
    private func cellIDForLinkCellInfo(linkCellInfo: LinkCellInfo) -> String {
        switch linkCellInfo.type {
        case .AddLink:
            return AddLinkCell.ID
        case .EnterLink:
            return EnterLinkCell.ID
        case .Link:
            return LinkCell.ID
        case .DeleteLink:
            return DeleteLinkCell.ID
        }
    }
}

extension DappLinksVCNew: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let existingLinkCellInfo = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
            linkCellsInfo: self.linkCellsInfo
        )
        
        if let linkCellInfo = existingLinkCellInfo {
            if linkCellInfo.type == .Link {
                let newLinkCellInfo = LinkCellInfo(
                    row:  linkCellInfo.row,
                    link: linkCellInfo.link,
                    type: .DeleteLink
                )
                
                self.linkCellsInfo = LinkCellInfoHelper.replaceLinkCellInfoWithRow(linkCellInfo.row,
                    withLinkCellInfo: newLinkCellInfo,
                    linkCellsInfo: self.linkCellsInfo
                )
                
                self.linksTableView.reloadData()
            }
        }
    }
}

extension DappLinksVCNew: AddLinkCellDelegate {
    func didTouchAddLinkButtonInCell(cell: AddLinkCell) {
        if let
            indexPath = self.linksTableView.indexPathForCell(cell),
            existingLinkCellInfo = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
                linkCellsInfo: self.linkCellsInfo
            ) {
                let linkCellInfoWithLinkType = LinkCellInfoHelper.linkCellInfoWithType(.EnterLink,
                    linkCellsInfo: self.linkCellsInfo
                )
                let thereAreNoEnterLinkCells = linkCellInfoWithLinkType == nil
                
                if thereAreNoEnterLinkCells {
                    let newLinkCellInfo = LinkCellInfo(
                        row:  existingLinkCellInfo.row,
                        link: nil,
                        type: .EnterLink
                    )
                    
                    self.linkCellsInfo = LinkCellInfoHelper.replaceLinkCellInfoWithRow(
                        existingLinkCellInfo.row,
                        withLinkCellInfo: newLinkCellInfo,
                        linkCellsInfo: self.linkCellsInfo
                    )
                    
                    self.linksTableView.reloadData()
                }
        }
    }
}

extension DappLinksVCNew: EnterLinkCellDelegate {
    func addLinkWithAddress(address: String, cell: EnterLinkCell) {
        if let
            indexPath = self.linksTableView.indexPathForCell(cell),
            existingLinkCellInfo = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
                linkCellsInfo: self.linkCellsInfo
            ) {
                DappLinkHelper.linkWithAddress(address, completion: {
                    (link: Link?, errorMessage: String?) -> Void in
                    cell.linkAddressTextField.text = ""
                    
                    if let link = link {
                        self.linkCellsInfo = LinkCellInfoHelper.deleteLinkCellInfoWithRow(
                            existingLinkCellInfo.row,
                            linkCellsInfo: self.linkCellsInfo
                        )
                        
                        let linksCount = LinkCellInfoHelper.countLinkCellsInfoWithType(.Link,
                            linkCellsInfo: self.linkCellsInfo
                        )
                        let newLinkCellInfo = LinkCellInfo(
                            row:  linksCount,
                            link: link,
                            type: .Link
                        )
                        
                        self.linkCellsInfo = LinkCellInfoHelper.inserLinkCellInfo(newLinkCellInfo,
                            linkCellsInfo: self.linkCellsInfo
                        )
                        self.linkCellsInfo = LinkCellInfoHelper.normalizeLinkCellsInfoByRows(
                            self.linkCellsInfo
                        )
                        
                        self.linksTableView.reloadData()
                    } else {
                        if let errorMessage = errorMessage {
                            UIAlertView(
                                title:             "",
                                message:           errorMessage,
                                delegate:          nil,
                                cancelButtonTitle: nil,
                            	otherButtonTitles: "OK"
                            ).show()
                        }
                        
                        let newLinkCellInfo = LinkCellInfo(
                            row:  existingLinkCellInfo.row,
                            link: nil,
                            type: .AddLink
                        )
                        
                        self.linkCellsInfo = LinkCellInfoHelper.replaceLinkCellInfoWithRow(
                            existingLinkCellInfo.row,
                            withLinkCellInfo: newLinkCellInfo,
                            linkCellsInfo: self.linkCellsInfo
                        )
                    }
                    
                    self.linksTableView.reloadData()
                })
        }
    }
}

extension DappLinksVCNew: DeleteLinkCellDelegate {
    func didTouchDeleteLinkButtonInCell(cell: DeleteLinkCell) {
        if let indexPath = self.linksTableView.indexPathForCell(cell) {
            self.linkCellsInfo = LinkCellInfoHelper.deleteLinkCellInfoWithRow(indexPath.row,
                linkCellsInfo: self.linkCellsInfo
            )
            
            self.linkCellsInfo = LinkCellInfoHelper.normalizeLinkCellsInfoByRows(self.linkCellsInfo)
            
            let newLinkCellInfo = LinkCellInfo(
                row:  self.linkCellsInfo.count,
                link: nil,
                type: .AddLink
            )
            
            self.linkCellsInfo.append(newLinkCellInfo)
            self.linksTableView.reloadData()
        }
    }
    
    func didTouchCancelDeletionButtonInCell(cell: DeleteLinkCell) {
        if let
            indexPath = self.linksTableView.indexPathForCell(cell),
            existingLinkCellInfo = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
                linkCellsInfo: self.linkCellsInfo
            ) {
                let newLinkCellInfo = LinkCellInfo(
                    row:  existingLinkCellInfo.row,
                    link: existingLinkCellInfo.link,
                    type: .Link
                )
                
                self.linkCellsInfo = LinkCellInfoHelper.replaceLinkCellInfoWithRow(
                    existingLinkCellInfo.row,
                    withLinkCellInfo: newLinkCellInfo,
                    linkCellsInfo: self.linkCellsInfo
                )
                
                self.linksTableView.reloadData()
        }
    }
}
