
//
//  LinkCell.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/16/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

enum State {
    case NoLink
    case EnterLink
    case Link
}

enum ViewsState {
    case Enabled
    case Disabled
}

protocol LinkCellDelegate {
    func didEnterURLString(URLString: String, cell: LinkCell)
}

class LinkCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var linkIndexLabel: UILabel!
    @IBOutlet weak var linkTitleLabel: UILabel!
    
    @IBOutlet var noLinkViews: [UIView]!
    @IBOutlet var enterLinkViews: [UIView]!
    @IBOutlet var linkViews: [UIView]!
    
    internal var delegate: LinkCellDelegate?
    internal private(set) var state: State = State.NoLink
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hideAllViewsExcept(self.viewsForState(self.state))
        
        let borderColor = UIColor(red:0.509, green:0.45, blue:0.564, alpha:1.0).CGColor
        
        self.containerView.layer.cornerRadius = 4.0
        self.containerView.layer.borderWidth = 4.0
        self.containerView.layer.borderColor = borderColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func handleDoneButtonTap() {
        self.delegate?.didEnterURLString(self.textField.text, cell: self)
    }
    
    // MARK: - internal
    
    internal func showViewsForState(state: State) {
        if self.state == state {
            return
        }
        
        self.state = state
        
        let views = self.viewsForState(state)
        
        self.hideAllViewsExcept(views)
    }
    
    internal func makeViews(viewsState: ViewsState) {
        let views = self.viewsForState(self.state)
        
        switch viewsState {
        case .Enabled:
            self.enableViews(views)
            
            break
        case .Disabled:
            self.disableViews(views)
            
            break
        }
    }
    
    internal func showLinkInfo(#linkIndex: Int, linkTitle: String) {
        self.linkIndexLabel.text = "\(linkIndex)"
        self.linkTitleLabel.text = linkTitle
    }
    
    // MARK: - private
    
    private func hideAllViewsExcept(views: [UIView]) {
        self.hideViews(self.noLinkViews)
        self.hideViews(self.enterLinkViews)
        self.hideViews(self.linkViews)
        self.showViews(views)
        self.enableViews(views)
    }
    
    private func enableViews(views: [UIView]) {
        for view in views {
            view.userInteractionEnabled = true
            view.alpha = 1.0
        }
    }
    
    private func disableViews(views: [UIView]) {
        for view in views {
            view.userInteractionEnabled = false
            view.alpha = 0.5
        }
    }
    
    private func hideViews(views: [UIView]) {
        for view in views {
            view.hidden = true
        }
    }
    
    private func showViews(views: [UIView]) {
        for view in views {
            view.hidden = false
        }
    }
    
    private func viewsForState(state: State) -> [UIView] {
        switch state {
        case .NoLink:    return self.noLinkViews
        case .EnterLink: return self.enterLinkViews
        case .Link:      return self.linkViews
        }
    }
}
