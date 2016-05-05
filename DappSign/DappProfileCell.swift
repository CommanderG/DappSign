//
//  DappProfileCell.swift
//  DappSign
//
//  Created by Admin on 3/21/15.
//  Copyright (c) 2015 DappSign. All rights reserved.
//

import UIKit

protocol DappProfileCellDelegate {
    func editLinkInCell(cell: DappProfileCell)
    func resubmitDappInCell(cell: DappProfileCell)
}

class DappProfileCell: SWTableViewCell {
    @IBOutlet weak var dappSignView: DappSignView!
    @IBOutlet weak var resubmitButton: UIButton!
    @IBOutlet weak var editLinksButton: UIButton!
    @IBOutlet weak var dappMappViewContainer: UIView!
    
    private var profileDappMappVC: ProfileDappMappVC? = nil
    
    internal var cellDelegate: DappProfileCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initButtons()
        self.addProfileDappMapp()
        
        self.dappMappViewContainer.backgroundColor = UIColor.clearColor()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions
    
    @IBAction func editLinks() {
        self.cellDelegate?.editLinkInCell(self)
    }
    
    @IBAction func resubmit() {
        self.cellDelegate?.resubmitDappInCell(self)
    }
    
    // MARK: - internal
    
    internal func showDappMappDataForDapp(dapp: PFObject) {
        self.profileDappMappVC?.showDappMappDataForDapp(dapp)
    }
    
    // MARK: - UI
    
    private func initButtons() {
        let clearColor = UIColor.clearColor()
        
        self.resubmitButton.backgroundColor = clearColor
        self.editLinksButton.backgroundColor = clearColor
        
        ViewHelper.initButtonLayer(self.resubmitButton)
        ViewHelper.initButtonLayer(self.editLinksButton)
    }
    
    private func addProfileDappMapp() {
        if self.profileDappMappVC != nil {
            return
        }
        
        self.profileDappMappVC = StoryboardHelper.instantiateProfileDappMappVC()
        
        if let profileDappMappVC = self.profileDappMappVC {
            let profileDappMappView = profileDappMappVC.view
            
            let width = CGRectGetWidth(self.dappMappViewContainer.frame)
            let height = CGRectGetHeight(self.dappMappViewContainer.frame)
            let frame = CGRectMake(0.0, 0.0, width, height)
            
            profileDappMappView.frame = frame;
            
            self.dappMappViewContainer.addSubview(profileDappMappView)
        }
    }
}
