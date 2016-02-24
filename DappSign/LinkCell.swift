//
//  LinkCell.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class LinkCell: UITableViewCell {
    @IBOutlet weak var linkIndexLabel: UILabel!
    @IBOutlet weak var linkTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func showLinkTitle(title: String) {
        var range = NSMakeRange(0, 1)
        let attributes = self.linkTitleLabel.attributedText?.attributesAtIndex(0,
            effectiveRange: &range
        )
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        
        self.linkTitleLabel.attributedText = attributedString
    }
}
