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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addLinkImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var linkIndexLabel: UILabel!
    @IBOutlet weak var linkTitleLabel: UILabel!
    @IBOutlet weak var deleteThisLinkLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet var noLinkViews: [UIView]!
    @IBOutlet var enterLinkViews: [UIView]!
    @IBOutlet var linkViews: [UIView]!
    @IBOutlet var deleteLinkViews: [UIView]!
    
    internal var delegate: DappLinkCellDelegate?
    internal private(set) var state: DappLinkCellState = .Empty
    
    private var containerViewBorderLayer: CAShapeLayer?
    
    internal let selectedBackgroundColor = UIColor(red:0, green:0.419, blue:0.705, alpha:1)
    internal let unselectedBackgroundColor = UIColor.clearColor()
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.backgroundColor = unselectedBackgroundColor
    }
    
    override func awakeFromNib() {
        self.hideAllViewsExcept(self.viewsForState(self.state))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        self.addLinkImageView.alpha = 0.45
        
        let borderColor = UIColor(white: 1.0, alpha: 0.25).CGColor
        
        self.containerView.layoutIfNeeded()
        
        let containerViewBorderLayer = self.getBorderLayerForView(self.containerView
        ,   strokeColor: borderColor
        )
        
        if self.state != .Empty && self.state != .Link {
            self.containerView.layer.addSublayer(containerViewBorderLayer)
        }
        
        self.containerViewBorderLayer = containerViewBorderLayer
        
        
        
        self.linkIndexLabel.layoutIfNeeded()
        
        let linkIndexLabelBorderLayer = self.getBorderLayerForView(self.linkIndexLabel
        ,   strokeColor: UIColor.whiteColor().CGColor
        )
        
        self.linkIndexLabel.layer.addSublayer(linkIndexLabelBorderLayer)
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
            
            break
        case .Disabled:
            self.disableViews(views)
            
            break
        }
    }
    
    internal func showLinkInfo(linkIndex linkIndex: Int, linkTitle: String) {
        self.linkIndexLabel.text = "\(linkIndex)"
        self.linkTitleLabel.text = linkTitle
    }
    
    // MARK: - private
    
    private func getBorderLayerForView(view: UIView, strokeColor: CGColor) -> CAShapeLayer {
        var roundedRect = view.bounds
        roundedRect.origin.x += 2.0
        roundedRect.origin.y += 2.0
        roundedRect.size.width -= roundedRect.origin.x * 2
        roundedRect.size.height -= roundedRect.origin.y * 2
        
        let borderLayer = CAShapeLayer()
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.path = UIBezierPath(roundedRect: roundedRect, cornerRadius: 10.0).CGPath
        borderLayer.frame = view.bounds
        borderLayer.strokeColor = strokeColor
        borderLayer.lineWidth = 4.0
        
        return borderLayer
    }
    
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
        
        if views == self.linkViews {
            let layerBorderColor = UIColor(white: 1.0, alpha: 0.75).CGColor
            
            self.containerViewBorderLayer?.removeFromSuperlayer()
            
            self.containerView.backgroundColor = self.selectedBackgroundColor
            self.containerView.layer.borderColor = layerBorderColor
            self.containerView.layer.borderWidth = 1.0
        } else {
            if let containerViewBorderLayer = self.containerViewBorderLayer {
            	self.containerView.layer.addSublayer(containerViewBorderLayer)
            }
            
            self.containerView.backgroundColor = self.unselectedBackgroundColor
            self.containerView.layer.borderColor = UIColor.clearColor().CGColor
            self.containerView.layer.borderWidth = 0.0
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
