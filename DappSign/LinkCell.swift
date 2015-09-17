
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
    
    private var containerViewBorderLayer: CAShapeLayer?
    
    internal let selectedBackgroundColor = UIColor(red:0.356, green:0.254, blue:0.448, alpha:1.0)
    internal let unselectedBackgroundColor = UIColor(red:0.458, green:0.360, blue:0.541, alpha:1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hideAllViewsExcept(self.viewsForState(self.state))
        
        self.backgroundColor = unselectedBackgroundColor
    }
    
    override func layoutSubviews() {
        let borderColor = UIColor(red:0.509, green:0.45, blue:0.564, alpha:1.0).CGColor
        
        
        
        self.containerView.layoutIfNeeded()
        
        let containerViewBorderLayer = self.getBorderLayerForView(self.containerView
        ,   strokeColor: borderColor
        )
        
        if state != State.Link {
            self.containerView.layer.addSublayer(containerViewBorderLayer)
        }
        
        self.containerViewBorderLayer = containerViewBorderLayer
        
        
        
        self.linkIndexLabel.layoutIfNeeded()
        
        let linkIndexLabelBorderLayer = self.getBorderLayerForView(self.linkIndexLabel
        ,   strokeColor: UIColor.whiteColor().CGColor
        )
        
        self.linkIndexLabel.layer.addSublayer(linkIndexLabelBorderLayer)
        
        
        
        super.layoutSubviews()
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
        self.showViews(views)
        self.enableViews(views)
        
        if views == self.enterLinkViews {
            self.textField.text = ""
        }
        
        if views == self.linkViews {
            let layerBorderColor = UIColor(red:0.592, green:0.592, blue:0.592, alpha:1.0).CGColor
            
            self.containerViewBorderLayer?.removeFromSuperlayer()
            
            self.containerView.backgroundColor = self.selectedBackgroundColor
            self.containerView.layer.borderColor = layerBorderColor
            self.containerView.layer.borderWidth = 1.0
        } else {
            self.containerView.layer.addSublayer(self.containerViewBorderLayer)
            
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
    
    private func viewsForState(state: State) -> [UIView] {
        switch state {
        case .NoLink:    return self.noLinkViews
        case .EnterLink: return self.enterLinkViews
        case .Link:      return self.linkViews
        }
    }
}
