//
//  DappCell.swift
//  DappSign
//
//  Created by Seshagiri Vakkalanka on 3/2/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappCell: UITableViewCell {

    @IBOutlet weak var dappCellTextView: UITextView!
    @IBOutlet weak var dappsWordLabel: UILabel!
    @IBOutlet weak var dappsNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
