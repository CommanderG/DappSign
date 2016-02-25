//
//  DappLinksVCNew.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

enum LinkCellType {
    case AddLink
    case EnterLink
    case Link
    case DeleteLink
}

struct Cell {
    var row:  Int
    var link: Link?
    var type: LinkCellType
}

class DappLinksVCNew: UIViewController {
    @IBOutlet weak var linksTableView: UITableView!
    
    private var cells: [Cell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
        
        self.linksTableView.estimatedRowHeight = 100.0
        self.linksTableView.rowHeight = UITableViewAutomaticDimension
        
        for row in 0 ... 3 {
            let cell = Cell(row: row, link: nil, type: .AddLink)
            
            self.cells.append(cell)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DappLinksVCNew: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells.count
    }
    
    func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cellID = self.cellIDForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        let linkIndex = indexPath.row + 1
        
        if let addLinkCell = cell as? AddLinkCell {
            addLinkCell.delegate = self
            
            addLinkCell.linkIndexLabel.text = "\(linkIndex)"
        } else if let enterLinkCell = cell as? EnterLinkCell {
            
        } else if let linkCell = cell as? LinkCell {
            linkCell.linkIndexLabel.text = "\(linkIndex)"
            linkCell.linkTitleLabel.text = ""
        } else if let deleteLinkcell = cell as? DeleteLinkCell {
            
        }
        
        return cell
    }
    
    // MARK: - private
    
    private func cellIDForIndexPath(indexPath: NSIndexPath) -> String {
        if let cell = self.cellWithRow(indexPath.row) {
            switch cell.type {
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
        
        return ""
    }
    
    private func cellWithRow(row: Int) -> Cell? {
        for cell in self.cells {
            if cell.row == row {
                return cell
            }
        }
        
        return nil
    }
    
    private func replaceCellWithRow(row: Int, withCell newCell: Cell) {
        for cellIndex in 0 ... self.cells.count - 1 {
            let cell = self.cells[cellIndex]
            
            if cell.row == row {
                self.cells.removeAtIndex(cellIndex)
                self.cells.append(newCell)
                
                break
            }
        }
    }
}

extension DappLinksVCNew: UITableViewDelegate {
    
}

extension DappLinksVCNew: AddLinkCellDelegate {
    func addLink(cell: AddLinkCell) {
        if let
            indexPath = self.linksTableView.indexPathForCell(cell),
            existingCell = self.cellWithRow(indexPath.row) {
                let newCell = Cell(row: existingCell.row, link: nil, type: .EnterLink)
                
                self.replaceCellWithRow(existingCell.row, withCell: newCell)
                self.linksTableView.reloadData()
        }
    }
}
