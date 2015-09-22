//
//  DappProfileCell.swift
//  DappSign
//
//  Created by Admin on 3/21/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

protocol DappProfileCellDelegate {
    func editLinkInCell(cell: DappProfileCell)
}

class DappProfileCell: SWTableViewCell {
    @IBOutlet weak var dappSignView: DappSignView!
    @IBOutlet weak var editLinksView: UIView!
    
    internal var cellDelegate: DappProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func editLinks() {
        self.cellDelegate?.editLinkInCell(self)
    }
}
