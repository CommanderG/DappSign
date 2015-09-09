//
//  DappProfileCell.swift
//  DappSign
//
//  Created by Admin on 3/21/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappProfileCell: SWTableViewCell {
    @IBOutlet weak var dappSignView: DappSignView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
