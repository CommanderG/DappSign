//
//  DappLinksView.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/21/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

class DappLinksView: XIBView {
    @IBOutlet weak var linksTableView: UITableView!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.cornerRadius = 12.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2.0
        
        self.linksTableView.estimatedRowHeight = 100.0
        self.linksTableView.rowHeight = UITableViewAutomaticDimension
    }
}
