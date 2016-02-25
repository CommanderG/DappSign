//
//  AddLinkCell.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol AddLinkCellDelegate: class {
    func addLink(cell: AddLinkCell)
}

class AddLinkCell: UITableViewCell {
    static let ID = "addLinkCell"
    
    @IBOutlet weak var linkIndexLabel: UILabel!
    
    internal weak var delegate: AddLinkCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func handleAddLinkButtonTouch() {
        self.delegate?.addLink(self)
    }
}
