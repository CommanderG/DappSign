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
    func resubmitDappInCell(cell: DappProfileCell)
}

class DappProfileCell: SWTableViewCell {
    @IBOutlet weak var dappSignView: DappSignView!
    @IBOutlet weak var resubmitButton: UIButton!
    @IBOutlet weak var editLinksButton: UIButton!
    
    internal var cellDelegate: DappProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ViewHelper.initButtonLayer(self.resubmitButton)
        ViewHelper.initButtonLayer(self.editLinksButton)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func editLinks() {
        self.cellDelegate?.editLinkInCell(self)
    }
    
    @IBAction func resubmit() {
        self.cellDelegate?.resubmitDappInCell(self)
    }
}
