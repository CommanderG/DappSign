//
//  DappLinksVCNew.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 2/24/16.
//  Copyright © 2016 DappSign. All rights reserved.
//

import UIKit

class DappLinksVCNew: UIViewController {
    @IBOutlet weak var linksTableView: UITableView!
    
    private var titles = ["How corporate lobbyists conquered American democracy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12.0
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.layer.borderWidth = 2.0
        
        self.linksTableView.estimatedRowHeight = 100.0
        self.linksTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DappLinksVCNew: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath
    ) -> UITableViewCell {
        let cellID = self.cellIDForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
        let linkIndex = indexPath.row + 1
        
        if let addLinkCell = cell as? AddLinkCell {
            addLinkCell.linkIndexLabel.text = "\(linkIndex)"
        } else if let enterLinkCell = cell as? EnterLinkCell {
            
        } else if let linkCell = cell as? LinkCell {
            linkCell.linkIndexLabel.text = "\(linkIndex)"
            
            let linkTitle = self.titles[indexPath.row]
            
//            linkCell.showLinkTitle(linkTitle)
        } else if let deleteLinkcell = cell as? DeleteLinkCell {
            
        }
        
        return cell
    }
    
    // MARK: - private
    
    private func cellIDForIndexPath(indexPath: NSIndexPath) -> String {
        if indexPath.row < self.titles.count {
            return "linkCell"
        } else {
            return "addLinkCell"
        }
        
//        switch indexPath.row {
//        case 0:
//            return "addLinkCell"
//        case 1:
//            return "enterLinkCell"
//        case 2:
//            return "linkCell"
//        case 3:
//            return "deleteLinkCell"
//        case _:
//            return "addLinkCell"
//        }
    }
}

extension DappLinksVCNew: UITableViewDelegate {
    
}
