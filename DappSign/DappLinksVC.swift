//
//  DappLinksVC.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol DappLinksVCDelegate: class {
    func addLink(link: Link, completion: (success: Bool, error: NSError?) -> Void)
    func deleteLink(linkToDelete: Link, completion: (success: Bool, error: NSError?) -> Void)
    func openLinkURL(linkURL: NSURL)
}

enum DappLinksVCMode {
    case AddEdit
    case Read
}

class DappLinksVC: UIViewController {
    @IBOutlet weak var linksTableView: UITableView!
    @IBOutlet weak var tableViewTopLC: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomLC: NSLayoutConstraint!
    
    private var linkCellsInfo: [LinkCellInfo] = []
    private var mode = DappLinksVCMode.AddEdit
    
    internal weak var delegate: DappLinksVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.linksTableView.estimatedRowHeight = 100.0
        self.linksTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func initWithMode(mode: DappLinksVCMode, andLinks links: [Link]) {
        self.linkCellsInfo.removeAll()
        
        self.mode = mode
        
        switch self.mode {
        case .AddEdit:
            if links.count > 0 {
                for row in 0 ..< links.count {
                    let link = links[row]
                    let linkCellInfo = LinkCellInfo(row: row, link: link, type: .Link)
                    
                    self.linkCellsInfo.append(linkCellInfo)
                }
            }
            
            let startRow = self.linkCellsInfo.count - 1
            let endRow = 3
            
            if startRow < endRow {
                for row in startRow ... endRow {
                    let linkCellInfo = LinkCellInfo(row: row, link: nil, type: .AddLink)
                    
                    self.linkCellsInfo.append(linkCellInfo)
                }
            }
        case .Read:
            for linkIndex in 0 ..< links.count {
                let link = links[linkIndex]
                let linkCellInfo = LinkCellInfo(row: linkIndex, link: link, type: .Link)
                
                self.linkCellsInfo.append(linkCellInfo)
            }
        }
        
        if self.linksTableView != nil {
            self.linksTableView.reloadData()
        }
    }
    
    internal func addBorder() {
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
    }
}

extension DappLinksVC: UITableViewDataSource {
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
            let cellID = self.cellIDForLinkCellInfo(linkCellInfo)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
            let linkIndex = indexPath.row + 1
            
            if let addLinkCell = cell as? AddLinkCell {
                addLinkCell.delegate = self
                addLinkCell.linkIndexLabel.text = "\(linkIndex)"
            } else if let enterLinkCell = cell as? EnterLinkCell {
                enterLinkCell.delegate = self
            } else if let linkCell = cell as? LinkCell {
                linkCell.delegate = self
                linkCell.linkIndexLabel.text = "\(linkIndex)"
                linkCell.linkTitleLabel.text = linkCellInfo.link?.title
            } else if let deleteLinkcell = cell as? DeleteLinkCell {
                deleteLinkcell.delegate = self
            }
            
            return cell
        } else {
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

extension DappLinksVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.showDeleteLinkCellAtIndexPath(indexPath)
    }
    
    // MARK: - private
    
    private func showDeleteLinkCellAtIndexPath(indexPath: NSIndexPath) {
        if self.delegate == nil {
            return
        }
        
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

extension DappLinksVC: AddLinkCellDelegate {
    func didTouchAddLinkButtonInCell(cell: AddLinkCell) {
        if self.delegate == nil {
            return;
        }
        
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

extension DappLinksVC: EnterLinkCellDelegate {
    func addLinkWithAddress(address: String, cell: EnterLinkCell) {
        guard
            let indexPath = self.linksTableView.indexPathForCell(cell),
            let existingLinkCellInfo = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
                linkCellsInfo: self.linkCellsInfo
            )
            else { return }
        
        cell.alpha = 0.5
        cell.userInteractionEnabled = false
        
        DappLinkHelper.linkWithAddress(address, completion: {
            (link: Link?, errorMessage: String?) -> Void in
            cell.alpha = 1.0
            cell.userInteractionEnabled = true
            cell.linkAddressTextField.text = ""
            
            if let link = link {
                self.addLink(link, existingLinkCellInfo: existingLinkCellInfo)
            } else {
                if let errorMessage = errorMessage {
                    self.showAlertViewWithOKButtonAndMessage(errorMessage)
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
        })
    }
    
    // MARK: - private
    
    private func addLink(link: Link, existingLinkCellInfo: LinkCellInfo) {
        self.delegate?.addLink(link, completion: {
            (success: Bool, error: NSError?) -> Void in
            if success {
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
                var errorMessage =
                    "Failed to add link with URL: \(link.URLStr) and title: \(link.title)."
                
                if let error = error {
                    errorMessage += " Error: \(error)."
                } else {
                    errorMessage += " Unknown error."
                }
                
                self.showAlertViewWithOKButtonAndMessage(errorMessage)
            }
            
            self.linksTableView.reloadData()
        })
    }
}

extension DappLinksVC: LinkCellDelegate {
    func didTouchLinkButtonInCell(cell: LinkCell) {
        switch self.mode {
        case .AddEdit:
            if let indexPath = self.linksTableView.indexPathForCell(cell) {
                self.showDeleteLinkCellAtIndexPath(indexPath)
            }
        case .Read:
            if let
                indexPath = self.linksTableView.indexPathForCell(cell),
                linkCellInfo = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
                    linkCellsInfo: self.linkCellsInfo
                ),
                link = linkCellInfo.link,
                linkURLStr = link.URLStr,
                linkURL = NSURL(string: linkURLStr) {
                    self.delegate?.openLinkURL(linkURL)
            }
        }
    }
}

extension DappLinksVC: DeleteLinkCellDelegate {
    func didTouchDeleteLinkButtonInCell(cell: DeleteLinkCell) {
        if let
            indexPath = self.linksTableView.indexPathForCell(cell),
            linkCellInfo = LinkCellInfoHelper.linkCellInfoWithRow(indexPath.row,
                linkCellsInfo: self.linkCellsInfo
            ),
            link = linkCellInfo.link {
                self.delegate?.deleteLink(link, completion: {
                    (success: Bool, error: NSError?) -> Void in
                    self.linkCellsInfo = LinkCellInfoHelper.deleteLinkCellInfoWithRow(indexPath.row,
                        linkCellsInfo: self.linkCellsInfo
                    )
                    
                    self.linkCellsInfo = LinkCellInfoHelper.normalizeLinkCellsInfoByRows(
                        self.linkCellsInfo
                    )
                    
                    let newLinkCellInfo = LinkCellInfo(
                        row:  self.linkCellsInfo.count,
                        link: nil,
                        type: .AddLink
                    )
                    
                    self.linkCellsInfo.append(newLinkCellInfo)
                    self.linksTableView.reloadData()
                })
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
