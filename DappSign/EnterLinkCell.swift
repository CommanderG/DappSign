//
//  EnterLinkCell.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

protocol EnterLinkCellDelegate: class {
    func addLinkWithAddress(address: String, cell: EnterLinkCell)
}

class EnterLinkCell: UITableViewCell {
    static let ID = "enterLinkCell"
    
    @IBOutlet weak var linkAddressTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    internal weak var delegate: EnterLinkCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.doneButton.layer.cornerRadius = 4.0
        self.doneButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.doneButton.layer.borderWidth = 2.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func handleDoneButtonTouch(sender: AnyObject) {
        if let linkAddress = self.linkAddressTextField.text {
            self.delegate?.addLinkWithAddress(linkAddress, cell: self)
        }
    }
}
