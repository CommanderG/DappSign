//
//  DeleteLinkCell.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol DeleteLinkCellDelegate: class {
    func didTouchDeleteLinkButtonInCell(cell: DeleteLinkCell)
    func didTouchCancelDeletionButtonInCell(cell: DeleteLinkCell)
}

class DeleteLinkCell: UITableViewCell {
    static let ID = "deleteLinkCell"
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    internal weak var delegate: DeleteLinkCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.deleteButton.layer.cornerRadius = 4.0
        self.deleteButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.deleteButton.layer.borderWidth = 2.0
        
        self.cancelButton.layer.cornerRadius = 4.0
        self.cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.cancelButton.layer.borderWidth = 2.0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func deleteLink(sender: AnyObject) {
        self.delegate?.didTouchDeleteLinkButtonInCell(self)
    }
    
    @IBAction func cancelDeletion(sender: AnyObject) {
        self.delegate?.didTouchCancelDeletionButtonInCell(self)
    }
}
