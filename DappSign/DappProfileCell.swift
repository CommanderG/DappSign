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
    func tweetPetitionInCell(cell: DappProfileCell)
    func postToFacebookPetitionInCell(cell: DappProfileCell)
}

class DappProfileCell: SWTableViewCell {
    @IBOutlet weak var dappSignView:          DappSignView!
    @IBOutlet weak var resubmitButton:        UIButton!
    @IBOutlet weak var editLinksButton:       UIButton!
    @IBOutlet weak var dappMappViewContainer: UIView!
    @IBOutlet weak var tweetButton:           UIButton!
    @IBOutlet weak var showLinksButton:       UIButton!
    @IBOutlet weak var postToFacebookButton:  UIButton!
    
    private var profileDappMappVC: ProfileDappMappVC? = nil
    private var embedDappVC: EmbedDappVC? = nil
    
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
    
    @IBAction func tweet() {
        self.cellDelegate?.tweetPetitionInCell(self)
    }
    
    @IBAction func showLinks() {
        if self.embedDappVC == nil {
            self.embedDappVC = StoryboardHelper.instantiateEmbedDappVC()
            
            self.embedDappVC?.delegate = self
        }
        
        if let embedDappVC = self.embedDappVC {
            var frame = embedDappVC.frameWithDappViewFrame(self.dappSignView.bounds)
            
            frame.size.height += 12.0
            
            embedDappVC.view.frame = frame
            
            self.dappSignView.addSubview(embedDappVC.view)
            self.disableSharingButtons()
        }
    }
    
    @IBAction func postToFacebook() {
        self.cellDelegate?.postToFacebookPetitionInCell(self)
    }
    
    // MARK: - internal
    
    internal func showDappMappDataForDapp(dapp: PFObject) {
        self.profileDappMappVC?.showDappMappDataForDapp(dapp)
        self.hideLinks()
    }
    
    private func hideLinks() {
        self.embedDappVC?.view.removeFromSuperview()
        self.enableSharingButtons()
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
    
    private func disableSharingButtons() {
        let buttons = [ self.tweetButton, self.showLinksButton, self.postToFacebookButton ]
        
        ViewHelper.disableButtons(buttons)
    }
    
    private func enableSharingButtons() {
        let buttons = [ self.tweetButton, self.showLinksButton, self.postToFacebookButton ]
        
        ViewHelper.enableButtons(buttons)
    }
}

extension DappProfileCell: EmbedDappDelegate {
    func didRemoveFromParentViewController() {
        self.enableSharingButtons()
    }
}
