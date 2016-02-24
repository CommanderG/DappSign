//
//  DappLinkCell.swift
//  DappSign
//
//  Created by Oleksiy Kovtun on 9/21/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

@objc enum DappLinkCellState: Int {
    case Empty
    case NoLink
    case EnterLink
    case Link
    case DeleteLink
}

enum ViewsState {
    case Enabled
    case Disabled
}

protocol DappLinkCellDelegate {
    func didEnterURLString(URLString: String, cell: DappLinkCell)
    func deleteLinkInCell(cell: DappLinkCell)
    func openLinkInCell(cell: DappLinkCell)
    func openLinkOnTap() -> Bool
}

class DappLinkCell: UITableViewCell {
    @IBOutlet weak var addLinkImageView:    UIImageView!
    @IBOutlet weak var textField:           UITextField!
    @IBOutlet weak var doneButton:          UIButton!
    @IBOutlet weak var linkIndexLabel:      UILabel!
    @IBOutlet weak var linkTitleLabel:      UILabel!
    @IBOutlet weak var deleteThisLinkLabel: UILabel!
    @IBOutlet weak var deleteButton:        UIButton!
    @IBOutlet weak var cancelButton:        UIButton!
    @IBOutlet weak var linkButton:          UIButton!
    
    @IBOutlet var noLinkViews:     [UIView]!
    @IBOutlet var enterLinkViews:  [UIView]!
    @IBOutlet var linkViews:       [UIView]!
    @IBOutlet var deleteLinkViews: [UIView]!
    
    internal var delegate: DappLinkCellDelegate?
    internal private(set) var state = DappLinkCellState.Empty
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func awakeFromNib() {
        let currentStateViews = self.viewsForState(self.state)
        
        self.hideAllViewsExcept(currentStateViews)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.linkIndexLabel.layoutIfNeeded()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func handleDoneButtonTap() {
        if let URLStr = self.textField.text {
        	self.delegate?.didEnterURLString(URLStr, cell: self)
        }
    }
    
    @IBAction func handleDeleteButtonTap() {
        self.delegate?.deleteLinkInCell(self)
    }
    
    @IBAction func handleCancelButtonTap() {
        self.goToState(.Link)
    }
    
    @IBAction func openLink() {
        self.delegate?.openLinkInCell(self)
    }
    
    // MARK: - internal
    
    internal func goToState(newState: DappLinkCellState) {
        if self.state == newState {
            return
        }
        
        self.state = newState
        
        let views = self.viewsForState(newState)
        
        self.hideAllViewsExcept(views)
        
        if let open = self.delegate?.openLinkOnTap() {
            self.linkButton.hidden = !open
        } else {
            self.linkButton.hidden = true
        }
    }
    
    internal func makeViews(viewsState: ViewsState) {
        let views = self.viewsForState(self.state)
        
        switch viewsState {
        case .Enabled:
            self.enableViews(views)
        case .Disabled:
            self.disableViews(views)
        }
    }
    
    // MARK: - private
    
    private func hideAllViewsExcept(views: [UIView]) {
        self.hideViews(self.noLinkViews)
        self.hideViews(self.enterLinkViews)
        self.hideViews(self.linkViews)
        self.hideViews(self.deleteLinkViews)
        
        self.showViews(views)
        self.enableViews(views)
        
        if views == self.enterLinkViews {
            self.textField.text = ""
        }
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
    
    private func viewsForState(state: DappLinkCellState) -> [UIView] {
        switch state {
        case .Empty:      return []
        case .NoLink:     return self.noLinkViews
        case .EnterLink:  return self.enterLinkViews
        case .Link:       return self.linkViews
        case .DeleteLink: return self.deleteLinkViews
        }
    }
}
