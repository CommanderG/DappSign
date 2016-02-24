//
//  DeleteLinkCell.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DeleteLinkCell: UITableViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
        print("deleteLink")
    }
    
    @IBAction func cancelDeletion(sender: AnyObject) {
        print("cancelDeletion")
    }
}
